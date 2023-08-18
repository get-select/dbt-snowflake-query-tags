{{
    config(
        meta={
            "owner": "@alice",
            "model_maturity": "in dev"
        },
        materialized="table",
        tags='a',
        query_tag="this will generate a warning"
    )
}}

select 1 as a
