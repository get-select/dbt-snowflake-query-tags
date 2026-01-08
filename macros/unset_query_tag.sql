{% macro unset_query_tag(original_query_tag) -%}
    {{ return(adapter.dispatch('unset_query_tag', 'dbt_snowflake_query_tags')(original_query_tag)) }}
{%- endmacro %}

