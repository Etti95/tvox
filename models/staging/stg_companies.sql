with source as (

    select * from {{ source('telavox_raw', 'raw_companies') }}
),

renamed as (

select 
    cast(company_id as string) as company_id,
    cast(company_name as string) as company_name,
    cast(country as string) as country,
    cast(industry as string) as industry,
    cast(employee_count as int) as employee_count,
    cast(account_owner as string) as account_owner,
    cast(created_at as timestamp) as created_at,
    cast(is_test_account as bool) as is_test_account

from source

)

select * from renamed