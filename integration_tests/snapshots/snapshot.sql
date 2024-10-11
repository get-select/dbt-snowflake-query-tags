{% snapshot test_snapshot %}

{{
    config(
        target_schema=target.schema,
        strategy='check',
        unique_key='a',
        check_cols=['b'],
    )
}}

select 1 as a, 2 as b

{% endsnapshot %}
