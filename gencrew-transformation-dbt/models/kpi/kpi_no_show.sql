-- Kpi: No Show %
-- Share of bookings that never arrived
-- numerator   : sum(is_no_show)
-- denominator : count(*)
-- grain       : date_trunc('month', booked_at)
-- source      : mapping sheet

select
        date_trunc('month', f.booked_at) as booked_at_month,
        round(100.0 * sum(f.is_no_show) / nullif(count(*), 0), 2) as no_show
from {{ ref('fact_reservations') }} as f
    group by 1
