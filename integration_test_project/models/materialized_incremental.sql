{{ config(materialized='incremental', tags=['a', 'b', 'c']) }}

select 1 as a

-- {{ ref('materialized_table') }}
-- {{ ref('materialized_view') }}
