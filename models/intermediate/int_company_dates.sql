with company_dates as (

    select 
        c.company_id,
        d.date_day

    from
        {{ ref('stg_companies') }} as c
    
    left join {{ ref('int_date_spine') }} as d on d.date_day >= date(c.created_at)
)

select * from company_dates