-- Kpi: Cancellation %
-- Share of bookings cancelled, per month
-- numerator   : sum(is_cancelled)
-- denominator : count(*)
-- grain       : date_trunc('month', booked_at)
-- source      : mapping sheet

select
        date_trunc('month', f.booked_at) as booked_at_month,
        round(100.0 * sum(f.is_cancelled) / nullif(count(*), 0), 2) as cancellation
from {{ ref('fact_reservations') }} as f
    group by 1
