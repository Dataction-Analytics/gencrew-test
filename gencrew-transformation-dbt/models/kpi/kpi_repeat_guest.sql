-- Kpi: Repeat Guest %
-- Guests who had stayed before, as a share of guests who stayed
-- numerator   : count(distinct case when dim_guests.dim_guests_key is not null and is_repeat_guest = 1 then dim_guests.dim_guests_key end)
-- denominator : count(distinct dim_guests.dim_guests_key)
-- grain       : date_trunc('month', booked_at)
-- source      : mapping sheet

select
        date_trunc('month', f.booked_at) as booked_at_month,
        round(100.0 * count(distinct case when dim_guests.dim_guests_key is not null and f.is_repeat_guest = 1 then dim_guests.dim_guests_key end) / nullif(count(distinct dim_guests.dim_guests_key), 0), 2) as repeat_guest
from {{ ref('fact_reservations') }} as f
    left join {{ ref('dim_guests') }} as dim_guests on f.dim_guests_key = dim_guests.dim_guests_key
    where f.is_realised = 1
    group by 1
