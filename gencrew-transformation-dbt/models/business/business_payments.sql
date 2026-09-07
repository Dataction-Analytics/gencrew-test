-- Business: cleansed and deduplicated payments.
-- Dedupe keeps ONE row per payment_id, the latest by paid_at. Rows are
-- filtered out of the result, never deleted from the source.
-- Incremental: only rows with paid_at beyond the last run's high-water mark are
-- read; they MERGE on payment_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'payments') }}
    {% if is_incremental() %} where paid_at > (select coalesce(max(paid_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

), ranked as (

    select
        *,
        row_number() over (
            partition by payment_id
            order by paid_at desc
        ) as _gencrew_rn
    from source

)

select
        card_last4 AS card_last_four,
        payment_amount,
        paid_at,
        ingested_at,
        payment_id,
        CASE WHEN LOWER(TRIM((LOWER(TRIM(method))))) = 'cc' THEN 'card' WHEN LOWER(TRIM(method)) = 'amex' THEN 'card' WHEN LOWER(TRIM(method)) = 'wire' THEN 'bank_transfer' WHEN LOWER(TRIM(method)) = 'credit card' THEN 'card' WHEN LOWER(TRIM(method)) = 'virtual_card' THEN 'card' ELSE method END AS method,
        LOWER(TRIM(status)) AS status
from ranked
where _gencrew_rn = 1
