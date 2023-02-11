{{ config(materialized='incremental') }}

select 1 as a

-- {{ ref('materialized_table') }}
