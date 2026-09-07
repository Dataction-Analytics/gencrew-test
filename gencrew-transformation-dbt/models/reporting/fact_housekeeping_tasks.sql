-- Gold fact: fact_housekeeping_tasks. Grain: one row per housekeeping_tasks record.
-- Incremental on task_date using MERGE.
-- Never delete-and-reload: the house rule forbids DELETE and TRUNCATE.
with s as (

    select * from {{ ref('business_housekeeping_tasks') }}

)

select
        {{ dbt_utils.generate_surrogate_key(['s.task_id']) }} as fact_housekeeping_tasks_key,
        coalesce(dim_hotels.dim_hotels_key, '-1') as dim_hotels_key,
        coalesce(dim_rooms.dim_rooms_key, '-1') as dim_rooms_key,
        s.minutes_taken,
        s.task_date,
        s.ingested_at,
        s.status
from s
    left join {{ ref('dim_hotels') }} as dim_hotels
        on s.hotel_id = dim_hotels.dim_hotels_nk
        and s.task_date >= dim_hotels.valid_from and s.task_date < dim_hotels.valid_to
    left join {{ ref('dim_rooms') }} as dim_rooms
        on s.room_id = dim_rooms.dim_rooms_nk
        and s.task_date >= dim_rooms.valid_from and s.task_date < dim_rooms.valid_to
    {% if is_incremental() %}
    where s.task_date > (select coalesce(max(task_date), '1900-01-01') from {{ this }})
    {% endif %}
