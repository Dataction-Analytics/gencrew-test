-- Business: cleansed and standardised reservation_rooms.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on reservation_room_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'reservation_rooms') }}
    {% if is_incremental() %} where ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        reservation_room_id,
        nightly_rate,
        ingested_at,
        room_id,
        room_type_id,
        rate_plan_id
from source
