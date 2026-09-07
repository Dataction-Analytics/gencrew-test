-- Business: cleansed and deduplicated housekeeping_tasks.
-- Dedupe keeps ONE row per task_id, the latest by task_date. Rows are
-- filtered out of the result, never deleted from the source.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on task_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'housekeeping_tasks') }}
    {% if is_incremental() %} where ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

), ranked as (

    select
        *,
        row_number() over (
            partition by task_id
            order by task_date desc
        ) as _gencrew_rn
    from source

)

select
        minutes_taken,
        task_date,
        ingested_at,
        hotel_id,
        room_id,
        task_id,
        LOWER(TRIM(status)) AS status
from ranked
where _gencrew_rn = 1
