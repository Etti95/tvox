-- one row per company per day

{{
    config(
        materialized='incremental',
        unique_key = ['date_day', 'company_id'],
        partition_by = {
            "field": "date_day",
            "data_type": "date"
        },
        cluster_by = ["company_id"]
    )
}}

with company_dates as (
    select * from {{ ref('int_company_dates') }}

{% if is_incremental() %}
    -- this filter will only be applied on an incremental run
    where date_day >= date_sub(current_date(), interval 3 day)
{% endif %}
),


company as (
    select * from {{ ref('dim_companies') }}
),

subscriptions as (
    select * from {{ ref('fct_daily_subscription_revenue') }}
),

platform_usage as (
    select * from {{ ref('fct_daily_platform_usage') }}
),

support_ticket_signals as (
    select * from {{ ref('fct_daily_support_tickets') }}
),

invoices as (
    select * from {{ ref('fct_monthly_invoice_status') }}
),

final as (

    select 
        cd.company_id,
        cd.date_day,


        c.company_name,
        c.country,
        c.employee_count,
        c.sales_segment,
        c.account_owner,
        c.created_at,
        c.is_test_account,
        c.total_users,
        c.active_users,

        coalesce(s.active_subscriptions, 0) as active_subscriptions,
        coalesce(s.active_mrr_sek, 0) as active_mrr,
        s.current_plan_type,

        coalesce(pu.total_events, 0) as total_events,
        coalesce(pu.voice_calls, 0) as voice_calls,
        coalesce(pu.sms_events, 0) as sms_events,
        coalesce(pu.sms_quantity, 0) as sms_quantity,
        coalesce(pu.api_calls, 0) as api_calls,
        coalesce(pu.contact_center_events, 0) as contact_center_events,
        coalesce(pu.meetings, 0) as meetings,
        coalesce(pu.pbx_updates, 0) as pbx_updates,
        coalesce(pu.voice_call_seconds, 0) as voice_call_seconds,
        coalesce(pu.meeting_seconds, 0) as meeting_seconds,
        coalesce(pu.active_users, 0) as daily_active_users,

        coalesce(sts.opened_tickets, 0) as opened_tickets,
        coalesce(sts.high_priority_tickets, 0) as high_priority_tickets,
        coalesce(sts.open_tickets, 0) as open_tickets,
        coalesce(sts.closed_tickets, 0) as closed_tickets,

        coalesce(i.invoiced_amount_sek, 0) as invoiced_amount_sek,
        coalesce(i.total_invoices, 0) as total_invoices,
        coalesce(i.paid_invoices, 0) as paid_invoices,
        coalesce(i.void_invoices, 0) as void_invoices,
        coalesce(i.paid_late_invoices, 0) as paid_late_invoices,
        coalesce(i.overdue_invoices, 0) as overdue_invoices,

        case 
            when coalesce(s.active_mrr_sek, 0) = 0 then 'inactive'
            when coalesce(i.overdue_invoices, 0) > 0 then 'billing_risk'
            when coalesce(sts.high_priority_tickets, 0) > 2 then 'high_risk'
            when coalesce(pu.total_events, 0) = 0 then 'usage_risk'
        else 'healthy'
        end as customer_health_status


    from company_dates as cd

    left join company as c on cd.company_id = c.company_id

    left join subscriptions as s on cd.company_id = s.company_id 
        and cd.date_day = s.date_day

    left join platform_usage as pu on cd.date_day = pu.event_date
        and cd.company_id = pu.company_id
    
    left join support_ticket_signals as sts on cd.date_day = sts.date_day
        and cd.company_id = sts.company_id

    left join invoices as i on cd.company_id = i.company_id
    and date_trunc(cd.date_day, month) = i.invoice_month
)

select * from final