{{ config(
    materialized = 'incremental',
    unique_key = ['event_date', 'company_id'],
    partition_by = {
        "field": "event_date",
        "data_type": "date"
    },
    cluster_by = ["company_id"]
) }}

with events as (
    select *
        from {{ ref('stg_platform_events') }}

    {% if is_incremental() %}
    where event_date >= date_sub(current_date(), interval 365 day)
    {% endif %}
),


aggregated as (
    
    select
        event_date,
        company_id,
        
        count(*) as total_events,
        countif(event_type = 'voice_call_started') as voice_calls,
        countif(event_type = 'sms_sent') as sms_events,
        sum(case when event_type = 'sms_sent' then quantity else 0 end) as sms_quantity,
        countif(event_type = 'api_call') as api_calls,
        countif(event_type = 'contact_center_ticket_created') as contact_center_events,
        countif(event_type = 'meeting_started') as meetings,
        countif(event_type = 'pbx_rule_updated') as pbx_updates,

        sum(case when event_type = 'voice_call_started' then coalesce(duration_seconds, 0) else 0 end) as voice_call_seconds,
        sum(case when event_type = 'meeting_started' then coalesce(duration_seconds, 0) else 0 end) as meeting_seconds,

        count(distinct user_id) as active_users

    from events

    where event_type in (
        'voice_call_started',
        'sms_sent',
        'api_call',
        'contact_center_ticket_created',
        'meeting_started',
        'pbx_rule_updated'
    )
    group by 1,2

)

select * from aggregated