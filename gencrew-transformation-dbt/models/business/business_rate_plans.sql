-- Business: cleansed and deduplicated rate_plans.
-- Dedupe keeps ONE row per rate_plan_id, the latest by ingested_at. Rows are
-- filtered out of the result, never deleted from the source.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on rate_plan_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'rate_plans') }}
    {% if is_incremental() %} where ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

), ranked as (

    select
        *,
        row_number() over (
            partition by rate_plan_id
            order by ingested_at desc
        ) as _gencrew_rn
    from source

)

select
        rate_plan_id,
        hotel_id,
        rate_plan_code,
        rate_plan_name,
        CASE WHEN LOWER(TRIM((LOWER(TRIM(board_type))))) = 'ai' THEN 'all_inclusive' WHEN LOWER(TRIM(board_type)) = 'bb' THEN 'bed_breakfast' WHEN LOWER(TRIM(board_type)) = 'fb' THEN 'full_board' WHEN LOWER(TRIM(board_type)) = 'hb' THEN 'half_board' WHEN LOWER(TRIM(board_type)) = 'ro' THEN 'room_only' ELSE board_type END AS board_type,
        is_refundable,
        source_system,
        ingested_at
from ranked
where _gencrew_rn = 1
