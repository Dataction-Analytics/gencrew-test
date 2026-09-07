-- Kpi: Total Bookings
-- Bookings that were not cancelled, per month
-- numerator   : count(*)
-- denominator : (none)
-- grain       : date_trunc('month', booked_at)
-- source      : mapping sheet

select
        date_trunc('month', f.booked_at) as booked_at_month,
        count(*) as total_bookings
from {{ ref('fact_reservations') }} as f
    where f.is_cancelled = 0
    group by 1
