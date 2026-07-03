with invoices as (
    select * from {{ ref('stg_invoices') }}
),


daily as (
    select 
        invoice_month,
        company_id,
        sum(amount_sek) as invoiced_amount_sek,
        count(*) as total_invoices,
        countif(invoice_status = 'paid') as paid_invoices,
        countif(invoice_status = 'void') as void_invoices,
        countif(invoice_status = 'paid_late') as paid_late_invoices,
        countif(invoice_status = 'overdue') as overdue_invoices

    from invoices

    group by 1,2
)

select * from daily