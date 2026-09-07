-- Business: cleansed and deduplicated hotels.
-- Dedupe keeps ONE row per hotel_id, the latest by ingested_at. Rows are
-- filtered out of the result, never deleted from the source.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on hotel_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'hotels') }}
    where total_rooms IS NOT NULL
      {% if is_incremental() %} and ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

), ranked as (

    select
        *,
        row_number() over (
            partition by hotel_id
            order by ingested_at desc
        ) as _gencrew_rn
    from source

)

select
        hotel_id,
        hotel_code,
        TRIM(hotel_name) AS hotel_name,
        TRY_CAST(star_rating::VARCHAR AS NUMBER(1,0)) AS star_rating,
        total_rooms,
        city,
        (TRY_CAST((UPPER(TRIM(country)))::VARCHAR AS CHAR(2))) AS country_code,
        brand,
        opened_on,
        timezone,
        source_system,
        ingested_at,
        batch_id
from ranked
where _gencrew_rn = 1
