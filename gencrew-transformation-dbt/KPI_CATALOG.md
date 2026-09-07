# KPI catalogue

Every KPI below was DECLARED on the mapping sheet — none is inferred. A KPI is
only emitted as a model when every column its formula names exists on the
reporting fact or a dimension it joins; otherwise it is listed here for a human.

| KPI | Formula | Grain | Status | Model / reason |
|---|---|---|---|---|
| Total Bookings | `count(*)` | date_trunc('month', booked_at) | emitted | kpi_total_bookings |
| Total Revenue | `sum(charge_amount)` | date_trunc('month', charge_date) | emitted | kpi_total_revenue |
| Occupancy % | `sum(rooms_sold) ÷ sum(rooms_available)` | dim_hotels.hotel_name | emitted | kpi_occupancy |
| ADR | `sum(room_revenue) ÷ sum(rooms_sold)` | date_trunc('month', business_date) | needs a human | numerator references 'room_revenue', which is not a column of fact_daily_hotel_performance or any dimension it joins |
| RevPAR | `sum(room_revenue) ÷ sum(rooms_available)` | date_trunc('month', business_date) | needs a human | numerator references 'room_revenue', which is not a column of fact_daily_hotel_performance or any dimension it joins |
| Cancellation % | `sum(is_cancelled) ÷ count(*)` | date_trunc('month', booked_at) | emitted | kpi_cancellation |
| Average Stay | `avg(length_of_stay)` | dim_hotels.hotel_name | emitted | kpi_average_stay |
| Repeat Guest % | `count(distinct case when dim_guests.dim_guests_key is not null and is_repeat_guest = 1 then dim_guests.dim_guests_key end) ÷ count(distinct dim_guests.dim_guests_key)` | date_trunc('month', booked_at) | emitted | kpi_repeat_guest |
| No Show % | `sum(is_no_show) ÷ count(*)` | date_trunc('month', booked_at) | emitted | kpi_no_show |
| Revenue by Channel | `sum(total_amount)` | dim_channels.channel_name | emitted | kpi_revenue_by_channel |
| Rooms Unsold | `sum(rooms_unsold)` | dim_hotels.hotel_name | emitted | kpi_rooms_unsold |
| Average Review Score | `avg(rating)` | dim_hotels.hotel_name | needs a human | numerator references 'rating', which is not a column of fact_reviews or any dimension it joins |
