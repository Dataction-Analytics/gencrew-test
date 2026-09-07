-- Business: cleansed and deduplicated guests.
-- Dedupe keeps ONE row per guest_id, the latest by created_at. Rows are
-- filtered out of the result, never deleted from the source.
-- Incremental: only rows with created_at beyond the last run's high-water mark are
-- read; they MERGE on guest_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'guests') }}
    {% if is_incremental() %} where created_at > (select coalesce(max(created_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

), ranked as (

    select
        *,
        row_number() over (
            partition by guest_id
            order by created_at desc
        ) as _gencrew_rn
    from source

)

select
        guest_id,
        guest_ref AS guest_reference,
        (INITCAP(TRIM((TRIM(full_name))))) AS guest_name,
        (TRIM((LOWER(TRIM(email))))) AS email_address,
        phone AS phone_number,
        (TRY_CAST((UPPER(TRIM((CASE WHEN LOWER(TRIM(country)) = 'uk' THEN 'GB' WHEN LOWER(TRIM(country)) = 'uae' THEN 'AE' WHEN LOWER(TRIM(country)) = 'usa' THEN 'US' WHEN LOWER(TRIM(country)) = 'india' THEN 'IN' WHEN LOWER(TRIM(country)) = 'italy' THEN 'IT' WHEN LOWER(TRIM(country)) = 'japan' THEN 'JP' WHEN LOWER(TRIM(country)) = 'spain' THEN 'ES' WHEN LOWER(TRIM(country)) = 'france' THEN 'FR' WHEN LOWER(TRIM(country)) = 'germany' THEN 'DE' WHEN LOWER(TRIM(country)) = 'thailand' THEN 'TH' WHEN LOWER(TRIM(country)) = 'australia' THEN 'AU' WHEN LOWER(TRIM(country)) = 'singapore' THEN 'SG' WHEN LOWER(TRIM(country)) = 'united states' THEN 'US' WHEN LOWER(TRIM(country)) = 'united kingdom' THEN 'GB' WHEN LOWER(TRIM(country)) = 'united arab emirates' THEN 'AE' ELSE country END))))::VARCHAR AS CHAR(2))) AS country_code,
        DATE_TRUNC('year', date_of_birth) AS date_of_birth,
        created_at,
        source_system,
        ingested_at,
        datediff('year', date_of_birth, current_date()) AS guest_age_years
from ranked
where _gencrew_rn = 1
