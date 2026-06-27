with source as (
        select * from {{ source("telavox_raw", "raw_cdc_subscription_changes") }}
),

renamed as (
    select 
        cast(change_id as string) as change_id,
        cast(subscription_id as string) as subscription_id,
        cast(company_id as string) as company_id,
        cast(operation as string) as operation,
        cast(changed_at as timestamp) as changed_at,
        cast(plan_type as string) as plan_type,
        cast(monthly_price_sek as int) as monthly_price_sek,
        cast(status as string) as status,
        cast(_cdc_sequence as int) as cdc_sequence
    
    from source
)

select * from renamed