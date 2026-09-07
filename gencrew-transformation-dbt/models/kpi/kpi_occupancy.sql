-- Kpi: Occupancy %
-- Room nights sold as a share of room nights available, per hotel
-- numerator   : sum(rooms_sold)
-- denominator : sum(rooms_available)
-- grain       : dim_hotels.hotel_name
-- source      : mapping sheet

select
        dim_hotels.hotel_name as hotels_hotel_name,
        round(100.0 * sum(f.rooms_sold) / nullif(sum(f.rooms_available), 0), 2) as occupancy
from {{ ref('fact_daily_hotel_performance') }} as f
    left join {{ ref('dim_hotels') }} as dim_hotels on f.dim_hotels_key = dim_hotels.dim_hotels_key
    group by 1
