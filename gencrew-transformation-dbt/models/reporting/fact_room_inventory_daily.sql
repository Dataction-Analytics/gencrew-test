-- Gold fact: fact_room_inventory_daily. Grain: one row per room_inventory_daily record.
-- Incremental on inventory_date using MERGE.
-- Never delete-and-reload: the house rule forbids DELETE and TRUNCATE.
with s as (

    select * from {{ ref('business_room_inventory_daily') }}

)

select
        {{ dbt_utils.generate_surrogate_key(['s.inventory_id']) }} as fact_room_inventory_daily_key,
        coalesce(dim_hotels.dim_hotels_key, '-1') as dim_hotels_key,
        s.rooms_available,
        s.rooms_out_of_order,
        s.inventory_date,
        s.ingested_at
from s
    left join {{ ref('dim_hotels') }} as dim_hotels
        on s.hotel_id = dim_hotels.dim_hotels_nk
        and s.inventory_date >= dim_hotels.valid_from and s.inventory_date < dim_hotels.valid_to
    {% if is_incremental() %}
    where s.inventory_date > (select coalesce(max(inventory_date), '1900-01-01') from {{ this }})
    {% endif %}
