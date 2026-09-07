# Business rules applied in the `business` layers

Each rule below came from the mapping sheet or was approved on the requirement,
and is applied by the `models/business/` models. A rule that could not be expressed as SQL is
marked so, and must be handled by a human before sign-off.

| Table | Column | Rule | Layer | Expressed as SQL | Source |
|---|---|---|---|---|---|
| reservations | reservation_id | Same booking lands from PMS and an OTA | cleansed | yes | Cleansing!row 2 |
| reservations | confirmation_no | Trim | cleansed | yes | Cleansing!row 3 |
| reservations | confirmation_no | Confirmation numbers compared case-blind | cleansed | yes | Cleansing!row 4 |
| reservations | status | Lowercase | cleansed | yes | Cleansing!row 5 |
| reservations | status | 15 status spellings arrive from 7 systems | cleansed | yes | Cleansing!row 6 |
| reservations | check_in_date | ISO, DD/MM/YYYY, MM/DD/YYYY and DD-Mon-YYYY all arrive | cleansed | yes | Cleansing!row 7 |
| reservations | check_out_date | Standardise date format | cleansed | yes | Cleansing!row 8 |
| reservations | currency | usd/USD/gbp/GBP | cleansed | yes | Cleansing!row 9 |
| reservations | guest_id | An orphan booking cannot be reported | cleansed | yes | Cleansing!row 10 |
| guests | guest_id | Remove duplicates | cleansed | yes | Cleansing!row 11 |
| guests | full_name | Some names arrive padded | cleansed | yes | Cleansing!row 12 |
| guests | full_name | Some arrive fully upper-cased | cleansed | yes | Cleansing!row 13 |
| guests | email | Lowercase | cleansed | yes | Cleansing!row 14 |
| guests | email | Trim | cleansed | yes | Cleansing!row 15 |
| guests | country | 27 country spellings to ISO-3166 alpha-2 | cleansed | yes | Cleansing!row 16 |
| guests | country | Uppercase | cleansed | yes | Cleansing!row 17 |
| hotels | hotel_id | Remove duplicates | cleansed | yes | Cleansing!row 18 |
| hotels | hotel_name | Trim | cleansed | yes | Cleansing!row 19 |
| hotels | total_rooms | Occupancy cannot be computed without it | cleansed | yes | Cleansing!row 20 |
| hotels | country | Uppercase | cleansed | yes | Cleansing!row 21 |
| room_types | room_type_id | Remove duplicates | cleansed | yes | Cleansing!row 22 |
| room_types | room_type_code | Uppercase | cleansed | yes | Cleansing!row 23 |
| room_types | room_type_code | 31 room-type spellings to 8 canonical codes | cleansed | yes | Cleansing!row 24 |
| rooms | room_id | Remove duplicates | cleansed | yes | Cleansing!row 25 |
| stay_nights | stay_night_id | Remove duplicates | cleansed | yes | Cleansing!row 26 |
| stay_nights | stay_date | Standardise date format | cleansed | yes | Cleansing!row 27 |
| daily_hotel_performance | performance_id | Remove duplicates | cleansed | yes | Cleansing!row 28 |
| daily_hotel_performance | rooms_available | The Occupancy denominator | cleansed | yes | Cleansing!row 29 |
| daily_hotel_performance | business_date | Standardise date format | cleansed | yes | Cleansing!row 30 |
| folio_charges | charge_id | Remove duplicates | cleansed | yes | Cleansing!row 31 |
| folio_charges | charge_type | Uppercase | cleansed | yes | Cleansing!row 32 |
| folio_charges | currency | Uppercase | cleansed | yes | Cleansing!row 33 |
| payments | payment_id | Remove duplicates | cleansed | yes | Cleansing!row 34 |
| payments | method | Lowercase | cleansed | yes | Cleansing!row 35 |
| payments | method | Payment methods must be consistent | cleansed | yes | Cleansing!row 36 |
| payments | status | Lowercase | cleansed | yes | Cleansing!row 37 |
| cancellations | cancellation_id | Remove duplicates | cleansed | **no — needs a human** | Cleansing!row 38 |
| loyalty_members | loyalty_id | Remove duplicates | cleansed | **no — needs a human** | Cleansing!row 39 |
| loyalty_members | tier | Lowercase | cleansed | **no — needs a human** | Cleansing!row 40 |
| loyalty_members | tier | Standardise values | cleansed | **no — needs a human** | Cleansing!row 41 |
| channels | channel_id | Remove duplicates | cleansed | yes | Cleansing!row 42 |
| reviews | review_id | Remove duplicates | cleansed | yes | Cleansing!row 43 |
| housekeeping_tasks | task_id | Remove duplicates | cleansed | yes | Cleansing!row 44 |
| housekeeping_tasks | status | Lowercase | cleansed | yes | Cleansing!row 45 |
| ota_feed_raw | feed_row_id | Remove duplicates | cleansed | **no — needs a human** | Cleansing!row 46 |
| ota_feed_raw | arrival | Feed dates arrive as free text | cleansed | **no — needs a human** | Cleansing!row 47 |
| ota_feed_raw | departure | Standardise date format | cleansed | **no — needs a human** | Cleansing!row 48 |
| ota_feed_raw | booking_status | Lowercase | cleansed | **no — needs a human** | Cleansing!row 49 |
| rate_plans | rate_plan_id | Remove duplicates | cleansed | yes | Cleansing!row 50 |
| rate_plans | board_type | Lowercase | cleansed | yes | Cleansing!row 51 |
| rate_plans | board_type | Standardise values | cleansed | yes | Cleansing!row 52 |
| reservations |  | Drives Cancellation % | business | yes | Transformation!row 2 |
| reservations |  | A booking that produced a stay | business | yes | Transformation!row 3 |
| reservations |  | Derive | business | yes | Transformation!row 4 |
| reservations |  | Room-nights, not just bookings | business | yes | Transformation!row 5 |
| daily_hotel_performance |  | Derive | business | yes | Transformation!row 6 |
| guests |  | Derive | business | yes | Transformation!row 7 |
| reservations | channel_id | Bookings with no channel report as unknown | business | yes | Transformation!row 8 |
| loyalty_members | tier | Default value | business | **no — needs a human** | Transformation!row 9 |
| reservations | reservation_id | Primary key | business | yes | Column Mapping!row 2 |
| reservations | reservation_id | Primary key | cleansed | yes | Column Mapping!row 2 |
| reservations | confirmation_no | Business key | business | yes | Column Mapping!row 3 |
| reservations | confirmation_no | Business key | cleansed | yes | Column Mapping!row 3 |
| reservations | hotel_id | cast to NUMBER(10,0) | cleansed | yes | Column Mapping!row 4 |
| reservations | guest_id | cast to NUMBER(10,0) | cleansed | yes | Column Mapping!row 5 |
| reservations | booked_at | cast to TIMESTAMP_NTZ | cleansed | **no — needs a human** | Column Mapping!row 6 |
| reservations | check_in_date | business name for check_in_date | business | yes | Column Mapping!row 7 |
| reservations | check_in_date | cast to DATE | cleansed | yes | Column Mapping!row 7 |
| reservations | check_out_date | business name for check_out_date | business | yes | Column Mapping!row 8 |
| reservations | check_out_date | cast to DATE | cleansed | yes | Column Mapping!row 8 |
| reservations | nights | business name for nights | business | yes | Column Mapping!row 9 |
| reservations | nights | cast to NUMBER(3,0) | cleansed | yes | Column Mapping!row 9 |
| reservations | status | business name for status | business | yes | Column Mapping!row 10 |
| reservations | status | cast to VARCHAR(24) | cleansed | yes | Column Mapping!row 10 |
| reservations | total_amount | cast to NUMBER(14,2) | cleansed | yes | Column Mapping!row 11 |
| guests | guest_id | cast to NUMBER(10,0) | cleansed | yes | Column Mapping!row 12 |
| guests | guest_ref | business name for guest_ref | business | yes | Column Mapping!row 13 |
| guests | guest_ref | cast to VARCHAR(16) | cleansed | yes | Column Mapping!row 13 |
| guests | full_name | business name for full_name | business | yes | Column Mapping!row 14 |
| guests | full_name | cast to VARCHAR(160) | cleansed | yes | Column Mapping!row 14 |
| guests | email | business name for email | business | yes | Column Mapping!row 15 |
| guests | email | cast to VARCHAR(160) | cleansed | yes | Column Mapping!row 15 |
| guests | phone | business name for phone | business | yes | Column Mapping!row 16 |
| guests | phone | cast to VARCHAR(32) | cleansed | yes | Column Mapping!row 16 |
| guests | country | ISO-3166 alpha-2 | business | yes | Column Mapping!row 17 |
| guests | country | ISO-3166 alpha-2 | cleansed | yes | Column Mapping!row 17 |
| guests | date_of_birth | cast to DATE | cleansed | yes | Column Mapping!row 18 |
| hotels | hotel_id | cast to NUMBER(10,0) | cleansed | yes | Column Mapping!row 19 |
| hotels | hotel_code | cast to VARCHAR(12) | cleansed | yes | Column Mapping!row 20 |
| hotels | hotel_name | Kept: KPIs group by hotel name | cleansed | yes | Column Mapping!row 21 |
| hotels | star_rating | cast to NUMBER(1,0) | cleansed | yes | Column Mapping!row 22 |
| hotels | total_rooms | Kept: capacity | cleansed | yes | Column Mapping!row 23 |
| hotels | city | cast to VARCHAR(80) | cleansed | yes | Column Mapping!row 24 |
| hotels | country | business name for country | business | yes | Column Mapping!row 25 |
| hotels | country | cast to CHAR(2) | cleansed | yes | Column Mapping!row 25 |
| daily_hotel_performance | performance_id | cast to NUMBER(10,0) | cleansed | yes | Column Mapping!row 26 |
| daily_hotel_performance | hotel_id | cast to NUMBER(10,0) | cleansed | yes | Column Mapping!row 27 |
| daily_hotel_performance | business_date | cast to DATE | cleansed | yes | Column Mapping!row 28 |
| daily_hotel_performance | rooms_available | cast to NUMBER(5,0) | cleansed | yes | Column Mapping!row 29 |
| daily_hotel_performance | rooms_sold | cast to NUMBER(5,0) | cleansed | yes | Column Mapping!row 30 |
| stay_nights | stay_night_id | cast to NUMBER(10,0) | cleansed | yes | Column Mapping!row 31 |
| stay_nights | stay_date | cast to DATE | cleansed | yes | Column Mapping!row 32 |
| room_types | room_type_code | cast to VARCHAR(24) | cleansed | yes | Column Mapping!row 33 |
| folio_charges | charge_type | business name for charge_type | business | yes | Column Mapping!row 34 |
| folio_charges | charge_type | cast to VARCHAR(32) | cleansed | yes | Column Mapping!row 34 |
| channels | channel_name | cast to VARCHAR(80) | cleansed | yes | Column Mapping!row 35 |
| loyalty_members | tier | business name for tier | business | **no — needs a human** | Column Mapping!row 36 |
| loyalty_members | tier | cast to VARCHAR(20) | cleansed | **no — needs a human** | Column Mapping!row 36 |
| reviews | rating | Type left blank — inferred from the Data Platform | business | yes | Column Mapping!row 37 |
| reviews | rating | Type left blank — inferred from the Data Platform [type DECIMAL(3, 0) inferred from the measured source for snowflake] | cleansed | yes | Column Mapping!row 37 |
| payments | card_last4 | Type left blank — inferred from the Data Platform | business | yes | Column Mapping!row 38 |
| payments | card_last4 | Type left blank — inferred from the Data Platform [type VARCHAR(8) inferred from the measured source for snowflake] | cleansed | yes | Column Mapping!row 38 |
