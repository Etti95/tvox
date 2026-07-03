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
    where date_day >= date_sub(current_date() - interval 3 day)
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

        c.company_id,
        c.company_name,
        c.country,
        c.employee_count,
        c.sales_segment,
        c.account_owner,
        c.created_at,
        c.is_test_account,
        c.total_users,
        c.active_users,

        s.date_day,
        s.company_id,
        s.active_subscriptions,
        s.active_mrr,
        s.current_plan_type,

        pu.event_date,
        pu.company_id,
        
        pu.total_events,
        pu.voice_calls,
        pu.sms_events,
        pu.sms_quantity,
        pu.api_calls,
        pu.contact_center_events,
        pu.meetings,
        pu.pbx_updates,
        pu.voice_call_seconds,
        pu.meeting_seconds,
        pu.active_users,

        sts.date_day,
        sts.company_id,
        sts.opened_tickets,
        sts.high_priority_tickets,
        sts.open_tickets,
        sts.closed_tickets,

        i.invoice_month,
        i.company_id,
        i.invoiced_amount_sek,
        i.total_invoices,
        i.paid_invoices,
        i.void_invoices,
        i.paid_late_invoices,
        i.overdue_invoices,

    case 
        when coalesce(s.active_mrr, 0) = 0 then 'inactive'
        when coalesce(i.overdue_invoices, 0) > 0 then 'billing risk'
        when coalesce(sts.high_priority_tickets, 0) > 2 then 'high risk'
        when coalesce(pu.total_events, 0) = 0 then 'usage risk'
    else 'healthy'
    end as customer_health_status


    from company_dates as cd

    left join company as cd on cd.company_id = c.company_id

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