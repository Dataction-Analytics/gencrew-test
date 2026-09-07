-- Business: cleansed and deduplicated rooms.
-- Dedupe keeps ONE row per room_id, the latest by ingested_at. Rows are
-- filtered out of the result, never deleted from the source.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on room_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'rooms') }}
    {% if is_incremental() %} where ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

), ranked as (

    select
        *,
        row_number() over (
            partition by room_id
            order by ingested_at desc
        ) as _gencrew_rn
    from source

)

select
        room_id,
        hotel_id,
        room_type_id,
        room_number,
        floor_no,
        is_active,
        source_system,
        ingested_at
from ranked
where _gencrew_rn = 1
