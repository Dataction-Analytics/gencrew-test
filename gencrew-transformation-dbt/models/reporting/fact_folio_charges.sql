-- Gold fact: fact_folio_charges. Grain: one row per folio_charges record.
-- Incremental on charge_date using MERGE.
-- Never delete-and-reload: the house rule forbids DELETE and TRUNCATE.
with s as (

    select * from {{ ref('business_folio_charges') }}

)

select
        {{ dbt_utils.generate_surrogate_key(['s.charge_id']) }} as fact_folio_charges_key,
        coalesce(dim_hotels.dim_hotels_key, '-1') as dim_hotels_key,
        s.charge_amount,
        s.charge_date,
        s.ingested_at,
        s.revenue_category,
        s.currency
from s
    left join {{ ref('dim_hotels') }} as dim_hotels
        on s.hotel_id = dim_hotels.dim_hotels_nk
        and s.charge_date >= dim_hotels.valid_from and s.charge_date < dim_hotels.valid_to
    {% if is_incremental() %}
    where s.charge_date > (select coalesce(max(charge_date), '1900-01-01') from {{ this }})
    {% endif %}
