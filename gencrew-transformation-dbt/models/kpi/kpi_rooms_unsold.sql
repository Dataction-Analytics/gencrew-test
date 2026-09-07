-- Kpi: Rooms Unsold
-- Unsold capacity, per hotel
-- numerator   : sum(rooms_unsold)
-- denominator : (none)
-- grain       : dim_hotels.hotel_name
-- source      : mapping sheet

select
        dim_hotels.hotel_name as hotels_hotel_name,
        sum(f.rooms_unsold) as rooms_unsold
from {{ ref('fact_daily_hotel_performance') }} as f
    left join {{ ref('dim_hotels') }} as dim_hotels on f.dim_hotels_key = dim_hotels.dim_hotels_key
    group by 1
