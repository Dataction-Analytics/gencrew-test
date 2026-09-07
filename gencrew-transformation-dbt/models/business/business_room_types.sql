-- Business: cleansed and deduplicated room_types.
-- Dedupe keeps ONE row per room_type_id, the latest by ingested_at. Rows are
-- filtered out of the result, never deleted from the source.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on room_type_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'room_types') }}
    {% if is_incremental() %} where ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

), ranked as (

    select
        *,
        row_number() over (
            partition by room_type_id
            order by ingested_at desc
        ) as _gencrew_rn
    from source

)

select
        CASE WHEN LOWER(TRIM((UPPER(TRIM(room_type_code))))) = 'dbl' THEN 'DBL' WHEN LOWER(TRIM(room_type_code)) = 'ada' THEN 'ACC' WHEN LOWER(TRIM(room_type_code)) = 'dbl' THEN 'DBL' WHEN LOWER(TRIM(room_type_code)) = 'exec' THEN 'EXE' WHEN LOWER(TRIM(room_type_code)) = 'king' THEN 'KNG' WHEN LOWER(TRIM(room_type_code)) = 'twin' THEN 'TWN' WHEN LOWER(TRIM(room_type_code)) = 'dlx-k' THEN 'KNG' WHEN LOWER(TRIM(room_type_code)) = 'suite' THEN 'STE' WHEN LOWER(TRIM(room_type_code)) = 'double' THEN 'DBL' WHEN LOWER(TRIM(room_type_code)) = 'family' THEN 'FAM' WHEN LOWER(TRIM(room_type_code)) = 'jr ste' THEN 'STE' WHEN LOWER(TRIM(room_type_code)) = 'single' THEN 'SGL' WHEN LOWER(TRIM(room_type_code)) = 'dbl room' THEN 'DBL' WHEN LOWER(TRIM(room_type_code)) = 'king bed' THEN 'KNG' WHEN LOWER(TRIM(room_type_code)) = 'executive' THEN 'EXE' WHEN LOWER(TRIM(room_type_code)) = 'twin beds' THEN 'TWN' WHEN LOWER(TRIM(room_type_code)) = 'twin room' THEN 'TWN' WHEN LOWER(TRIM(room_type_code)) = 'accessible' THEN 'ACC' WHEN LOWER(TRIM(room_type_code)) = 'deluxe king' THEN 'KNG' WHEN LOWER(TRIM(room_type_code)) = 'double room' THEN 'DBL' WHEN LOWER(TRIM(room_type_code)) = 'family room' THEN 'FAM' WHEN LOWER(TRIM(room_type_code)) = 'single room' THEN 'SGL' WHEN LOWER(TRIM(room_type_code)) = 'junior suite' THEN 'STE' WHEN LOWER(TRIM(room_type_code)) = 'executive room' THEN 'EXE' WHEN LOWER(TRIM(room_type_code)) = 'accessible room' THEN 'ACC' ELSE room_type_code END AS room_type_code,
        room_type_id,
        hotel_id,
        room_type_name,
        max_occupancy,
        source_system,
        ingested_at,
        base_rate
from ranked
where _gencrew_rn = 1
