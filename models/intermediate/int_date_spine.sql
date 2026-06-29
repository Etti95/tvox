
with min_dates as (
    select min(date(created_at)) as min_date
    from {{ ref('stg_companies')}}
),




date_spine as (
    select date_day
    from
        min_dates,
        unnest(generate_date_array(min_date, current_date())) as date_day
)

select * from date_spine