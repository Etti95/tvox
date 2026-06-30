with support_tickets as (
    select * from {{ ref('stg_support_tickets') }}
),

daily as (

    select 
        opened_at as date_day,
        company_id,
        count(*) as opened_tickets,
        countif(priority in ('high', 'urgent')) as high_priority_tickets,
        countif(status = 'open') as open_tickets,
        countif(status = 'closed') as closed_tickets




    from support_tickets

    group by 1,2
)

select * from daily