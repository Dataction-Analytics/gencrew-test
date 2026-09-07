-- Business: cleansed and deduplicated stay_nights.
-- Dedupe keeps ONE row per stay_night_id, the latest by stay_date. Rows are
-- filtered out of the result, never deleted from the source.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on stay_night_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'stay_nights') }}
    {% if is_incremental() %} where ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

), ranked as (

    select
        *,
        row_number() over (
            partition by stay_night_id
            order by stay_date desc
        ) as _gencrew_rn
    from source

)

select
        stay_night_id,
        TRY_TO_DATE(stay_date::VARCHAR) AS stay_date,
        is_occupied,
        room_revenue,
        ingested_at,
        hotel_id,
        room_id,
        room_type_id
from ranked
where _gencrew_rn = 1
