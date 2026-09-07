-- Kpi: Revenue by Channel
-- Booking value attributed to each channel
-- numerator   : sum(total_amount)
-- denominator : (none)
-- grain       : dim_channels.channel_name
-- source      : mapping sheet

select
        dim_channels.channel_name as channels_channel_name,
        sum(f.total_amount) as revenue_by_channel
from {{ ref('fact_reservations') }} as f
    left join {{ ref('dim_channels') }} as dim_channels on f.dim_channels_key = dim_channels.dim_channels_key
    where f.is_realised = 1
    group by 1
