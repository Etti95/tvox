with source as (
    select * from {{ source("telavox_raw", "raw_subscriptions") }}
),

renamed as (
    select 
        cast(subscription_id as string) as subscription_id,
        cast(company_id as string) as company_id,
        cast(plan_type as string) as plan_type,
        cast(monthly_price_sek as int) as monthly_price_sek,
        cast(status as string) as status,
        cast(valid_from as timestamp) as valid_from,
        cast(valid_to as timestamp) as valid_to,
        cast(billing_period as string) as billing_period

    from source
)

select * from renamed