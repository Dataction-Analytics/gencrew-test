-- Kpi: Average Stay
-- Mean nights per realised stay, per hotel
-- numerator   : avg(length_of_stay)
-- denominator : (none)
-- grain       : dim_hotels.hotel_name
-- source      : mapping sheet

select
        dim_hotels.hotel_name as hotels_hotel_name,
        avg(f.length_of_stay) as average_stay
from {{ ref('fact_reservations') }} as f
    left join {{ ref('dim_rate_plans') }} as dim_rate_plans on f.dim_rate_plans_key = dim_rate_plans.dim_rate_plans_key
    left join {{ ref('dim_hotels') }} as dim_hotels on dim_rate_plans.hotel_id = dim_hotels.dim_hotels_nk and dim_hotels.is_current
    where f.is_realised = 1
    group by 1
