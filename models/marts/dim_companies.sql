with companies as (
    select * from {{ ref('stg_companies') }}
),

users as(

    select 
        company_id,
        count(*) as total_users,
        countif(deactivated_at is null) as active_users

    from {{ ref('stg_users') }}
)

select  
    c.company_id,
    c.company_name,
    c.country,
    c.employee_count,
    c.sales_segment,
    c.account_owner,
    c.created_at,
    c.is_test_account,

    coalesce(u.total_users, 0) as total_users,
    coalesce(u.active_users) as active_users

from 
    companies as c

left join users as u 
    on c.company_id = u.company_id



