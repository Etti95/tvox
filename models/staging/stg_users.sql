with source as (
    select * from {{ source("telavox_raw", "raw_users") }}
),

renamed as (
    select
        cast(user_id as string) as user_id,
        cast(company_id as string) as company_id,
        cast(email as string) as email, 
        cast(user_role as string) as user_role,
        cast(created_at as timestamp) as created_at,
        cast(deactivated_at as timestamp) as deactivated_at

    from source
)

select * from renamed