with source as (    
    
    select * from {{ source('telavox_raw', 'raw_invoices') }}
),

renamed as (
    select
    cast(invoice_id as string) as invoice_id,
    cast(company_id as string) as company_id,
    cast(invoice_month as date) as invoice_month,
    cast(invoice_date as timestamp) as invoice_date,
    cast(amount_sek as int) as amount_sek,
    cast(status as string) as status,
    cast(paid_at as timestamp) as paid_at


    from source
)

select * from source
