with companies as (

    select *
    from {{ ref('stg_companies') }}

),

date_spine as (

    select *
    from {{ ref('int_date_spine') }}

),

company_dates as (

    select 
        c.company_id,
        d.date_day

    from companies as c

    cross join date_spine as d

    where d.date_day >= date(c.created_at)

)

select * from company_dates