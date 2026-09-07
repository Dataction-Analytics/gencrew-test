-- Kpi: Total Revenue
-- All folio revenue (room + ancillary), per month
-- numerator   : sum(charge_amount)
-- denominator : (none)
-- grain       : date_trunc('month', charge_date)
-- source      : mapping sheet

select
        date_trunc('month', f.charge_date) as charge_date_month,
        sum(f.charge_amount) as total_revenue
from {{ ref('fact_folio_charges') }} as f
    group by 1
