-- Gold fact: fact_reviews. Grain: one row per reviews record.
-- Incremental on submitted_at using MERGE.
-- Never delete-and-reload: the house rule forbids DELETE and TRUNCATE.
with s as (

    select * from {{ ref('business_reviews') }}

)

select
        {{ dbt_utils.generate_surrogate_key(['s.review_id']) }} as fact_reviews_key,
        coalesce(dim_hotels.dim_hotels_key, '-1') as dim_hotels_key,
        coalesce(dim_guests.dim_guests_key, '-1') as dim_guests_key,
        s.guest_rating,
        s.cleanliness,
        s.service_score,
        s.value_score,
        s.submitted_at,
        s.ingested_at
from s
    left join {{ ref('dim_hotels') }} as dim_hotels
        on s.hotel_id = dim_hotels.dim_hotels_nk
        and s.submitted_at >= dim_hotels.valid_from and s.submitted_at < dim_hotels.valid_to
    left join {{ ref('dim_guests') }} as dim_guests
        on s.guest_id = dim_guests.dim_guests_nk
        and s.submitted_at >= dim_guests.valid_from and s.submitted_at < dim_guests.valid_to
    {% if is_incremental() %}
    where s.submitted_at > (select coalesce(max(submitted_at), '1900-01-01') from {{ this }})
    {% endif %}
