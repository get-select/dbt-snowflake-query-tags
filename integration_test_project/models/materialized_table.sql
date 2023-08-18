{{
    config(
        meta={
            "owner": "@alice",
            "model_maturity": "in dev"
        },
        materialized="table",
        tags='a',
        query_tag='data team'
    )
}}

select 1 as a
