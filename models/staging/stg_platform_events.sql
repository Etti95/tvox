with source as (

    select * 
        from {{ source("telavox_raw", "raw_platform_events") }}
),

renamed as (
    select 
        cast(event_id as string) as event_id,
        cast(company_id as string) as company_id,
        cast(user_id as string) as user_id,
        cast(event_type as string) as event_type,
        cast(event_timestamp as timestamp) as event_timestamp,
        cast(quantity as int) as quantity,
        cast(duration_seconds as int64) as duration_seconds,
        cast(source_system as string) as source_system,
        cast(ingested_at as timestamp) as ingested_at
        

    from source
)

select * from renamed