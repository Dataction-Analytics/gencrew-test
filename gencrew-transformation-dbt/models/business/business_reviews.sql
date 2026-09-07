-- Business: cleansed and deduplicated reviews.
-- Dedupe keeps ONE row per review_id, the latest by submitted_at. Rows are
-- filtered out of the result, never deleted from the source.
-- Incremental: only rows with submitted_at beyond the last run's high-water mark are
-- read; they MERGE on review_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'reviews') }}
    {% if is_incremental() %} where submitted_at > (select coalesce(max(submitted_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

), ranked as (

    select
        *,
        row_number() over (
            partition by review_id
            order by submitted_at desc
        ) as _gencrew_rn
    from source

)

select
        rating AS guest_rating,
        cleanliness,
        service_score,
        value_score,
        submitted_at,
        ingested_at,
        hotel_id,
        guest_id,
        review_id
from ranked
where _gencrew_rn = 1
