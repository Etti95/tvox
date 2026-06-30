with subs as (
    select * from {{ ref('stg_subscriptions') }}
),

company_dates as (
    select * from {{ ref('int_company_dates') }}
),


active_subscription_days as (

    select
        cd.date_day,
        cd.company_id,
        count(distinct s.subscription_id) as active_subscriptions,
        sum(coalesce(s.monthly_price_sek, 0)) as active_mrr,
        max(s.plan_type) as current_plan_type


    from subs as s
    left join
        company_dates as cd on s.company_id = cd.company_id
        and cd.date_day >= date(s.valid_from)
        and (s.valid_to is null or date(s.valid_to) > cd.date_day)
        and s.status = 'active'

    group by 1,2

)

    select 
        date_day,
        company_id,
        coalesce(active_subscriptions, 0) as active_subscriptions,
        active_mrr as active_mrr_sek,
        current_plan_type

    from 
        active_subscription_days