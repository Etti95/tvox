with subscriptions as (
    select * from {{ ref('stg_subscriptions') }}
),



plans as (
    select * from {{ ref('plan_reference') }}
),


final as (

    select
        s.subscription_id,
        s.company_id,
        s.plan_type,
        s.monthly_price_sek,
        s.status,
        s.valid_from,
        s.valid_to,
        s.billing_period,

        coalesce(p.list_price_sek, 0) as list_price_sek,
        coalesce(p.included_users,0) as included_users,
        coalesce(p.included_minutes,0) as included_minutes


    from
        subscriptions s

    left join plans p on s.plan_type = p.plan_type
)

select * from final