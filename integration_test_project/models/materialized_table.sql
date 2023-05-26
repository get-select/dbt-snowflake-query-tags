{{
    config(
        meta={
            "owner": "@alice", 
            "model_maturity": "in dev"
        },
        materialized="table",
        tags='a'
    )
}}

select 1 as a
