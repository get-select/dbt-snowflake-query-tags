{% macro set_query_tag(extra = {}) -%}
    {{ return(adapter.dispatch('set_query_tag', 'dbt_snowflake_query_tags')(extra=extra)) }}
{%- endmacro %}

