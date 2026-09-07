-- Business: cleansed and standardised room_inventory_daily.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on inventory_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'room_inventory_daily') }}
    {% if is_incremental() %} where ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        inventory_id,
        rooms_available,
        rooms_out_of_order,
        inventory_date,
        ingested_at,
        hotel_id
from source
