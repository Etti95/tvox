with source as (
        select * from {{ source("telavox_raw", "raw_support_tickets") }}
),

renamed as (
    select
        cast(ticket_id as string) as ticket_id,
        cast(company_id as string) as company_id,
        cast(opened_at as timestamp) as opened_at,
        cast(closed_at as timestamp) as closed_at,
        cast(priority as string) as priority,
        cast(category as string) as category,
        cast(status as string) as status

    from source
)

select * from renamed