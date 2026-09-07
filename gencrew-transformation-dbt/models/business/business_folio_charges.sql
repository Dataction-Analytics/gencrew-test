-- Business: cleansed and deduplicated folio_charges.
-- Dedupe keeps ONE row per charge_id, the latest by charge_date. Rows are
-- filtered out of the result, never deleted from the source.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on charge_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'folio_charges') }}
    {% if is_incremental() %} where ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

), ranked as (

    select
        *,
        row_number() over (
            partition by charge_id
            order by charge_date desc
        ) as _gencrew_rn
    from source

)

select
        (UPPER(TRIM(charge_type))) AS revenue_category,
        charge_amount,
        charge_date,
        ingested_at,
        hotel_id,
        charge_id,
        UPPER(TRIM(currency)) AS currency
from ranked
where _gencrew_rn = 1
