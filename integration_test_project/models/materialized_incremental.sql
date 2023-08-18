{{ config(materialized='incremental', tags=['a', 'b', 'c'], query_tag={'test': 'test'}) }}

select 1 as a

-- {{ ref('materialized_table') }}
-- {{ ref('materialized_view') }}
