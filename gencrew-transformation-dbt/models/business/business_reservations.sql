-- Business: cleansed and deduplicated reservations.
-- Dedupe keeps ONE row per reservation_id, the latest by booked_at. Rows are
-- filtered out of the result, never deleted from the source.
-- Incremental: only rows with booked_at beyond the last run's high-water mark are
-- read; they MERGE on reservation_id. Nothing is deleted or truncated.
-- Rules recorded but NOT expressible as SQL here; they are listed in
-- BUSINESS_RULES.md and must be reviewed by a human:
--   * cast to TIMESTAMP_NTZ

with source as (

    select * from {{ source('raw', 'reservations') }}
    where guest_id IS NOT NULL
      {% if is_incremental() %} and booked_at > (select coalesce(max(booked_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

), ranked as (

    select
        *,
        row_number() over (
            partition by reservation_id
            order by booked_at desc
        ) as _gencrew_rn
    from source

)

select
        reservation_id AS booking_id,
        (UPPER(TRIM((TRIM(confirmation_no))))) AS confirmation_number,
        hotel_id,
        guest_id,
        booked_at,
        (TRY_CAST((TRY_TO_DATE(check_in_date::VARCHAR))::VARCHAR AS DATE)) AS arrival_date,
        (TRY_CAST((TRY_TO_DATE(check_out_date::VARCHAR))::VARCHAR AS DATE)) AS departure_date,
        (TRY_CAST(nights::VARCHAR AS NUMBER(3,0))) AS length_of_stay,
        (CASE WHEN LOWER(TRIM((LOWER(TRIM(status))))) = 'co' THEN 'checked_out' WHEN LOWER(TRIM(status)) = 'ns' THEN 'no_show' WHEN LOWER(TRIM(status)) = 'cnf' THEN 'confirmed' WHEN LOWER(TRIM(status)) = 'cxl' THEN 'cancelled' WHEN LOWER(TRIM(status)) = 'conf' THEN 'confirmed' WHEN LOWER(TRIM(status)) = 'noshow' THEN 'no_show' WHEN LOWER(TRIM(status)) = 'no show' THEN 'no_show' WHEN LOWER(TRIM(status)) = 'canceled' THEN 'cancelled' WHEN LOWER(TRIM(status)) = 'checkedout' THEN 'checked_out' WHEN LOWER(TRIM(status)) = 'checked out' THEN 'checked_out' WHEN LOWER(TRIM(status)) = 'checked-out' THEN 'checked_out' ELSE status END) AS booking_status,
        total_amount,
        adults,
        children,
        rooms_booked,
        is_repeat_guest,
        ingested_at,
        COALESCE(channel_id, '0') AS channel_id,
        rate_plan_id,
        UPPER(TRIM(currency)) AS currency,
        CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END AS is_cancelled,
        CASE WHEN status IN ('confirmed','checked_out') THEN 1 ELSE 0 END AS is_realised,
        CASE WHEN status = 'no_show' THEN 1 ELSE 0 END AS is_no_show,
        nights * rooms_booked AS room_nights_booked
from ranked
where _gencrew_rn = 1
