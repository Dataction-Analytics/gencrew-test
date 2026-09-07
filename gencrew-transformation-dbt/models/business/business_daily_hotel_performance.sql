-- Business: cleansed and deduplicated daily_hotel_performance.
-- Dedupe keeps ONE row per performance_id, the latest by business_date. Rows are
-- filtered out of the result, never deleted from the source.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on performance_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'daily_hotel_performance') }}
    where rooms_available IS NOT NULL
      {% if is_incremental() %} and ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

), ranked as (

    select
        *,
        row_number() over (
            partition by performance_id
            order by business_date desc
        ) as _gencrew_rn
    from source

)

select
        performance_id,
        hotel_id,
        TRY_TO_DATE(business_date::VARCHAR) AS business_date,
        rooms_available,
        rooms_sold,
        rooms_out_of_order,
        arrivals,
        departures,
        other_revenue,
        ingested_at,
        rooms_available - rooms_sold AS rooms_unsold
from ranked
where _gencrew_rn = 1
