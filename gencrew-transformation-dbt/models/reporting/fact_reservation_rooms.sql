-- Gold fact: fact_reservation_rooms. Grain: one row per reservation_rooms record.
-- Incremental on ingested_at using MERGE.
-- Never delete-and-reload: the house rule forbids DELETE and TRUNCATE.
with s as (

    select * from {{ ref('business_reservation_rooms') }}

)

select
        {{ dbt_utils.generate_surrogate_key(['s.reservation_room_id']) }} as fact_reservation_rooms_key,
        coalesce(dim_rooms.dim_rooms_key, '-1') as dim_rooms_key,
        coalesce(dim_room_types.dim_room_types_key, '-1') as dim_room_types_key,
        coalesce(dim_rate_plans.dim_rate_plans_key, '-1') as dim_rate_plans_key,
        s.nightly_rate,
        s.ingested_at
from s
    left join {{ ref('dim_rooms') }} as dim_rooms
        on s.room_id = dim_rooms.dim_rooms_nk
        and s.ingested_at >= dim_rooms.valid_from and s.ingested_at < dim_rooms.valid_to
    left join {{ ref('dim_room_types') }} as dim_room_types
        on s.room_type_id = dim_room_types.dim_room_types_nk
        and s.ingested_at >= dim_room_types.valid_from and s.ingested_at < dim_room_types.valid_to
    left join {{ ref('dim_rate_plans') }} as dim_rate_plans
        on s.rate_plan_id = dim_rate_plans.dim_rate_plans_nk
        and s.ingested_at >= dim_rate_plans.valid_from and s.ingested_at < dim_rate_plans.valid_to
    {% if is_incremental() %}
    where s.ingested_at > (select coalesce(max(ingested_at), '1900-01-01') from {{ this }})
    {% endif %}
