{% macro set_query_tag() -%}
    {{ return(adapter.dispatch('set_query_tag', 'dbt_snowflake_query_tags')()) }}
{%- endmacro %}

{% macro default__set_query_tag() -%}
    {# Start with any model-configured dict #}
    {% set tag_dict = config.get('query_tag', default={}) %}

    {%- do tag_dict.update(
        app='dbt',
        dbt_snowflake_query_tags_version='2.0.1',
    ) -%}

    {# We have to bring is_incremental through here because its not available in the comment context #}
    {% if model.resource_type == 'model' %}
        {%- do tag_dict.update(
            is_incremental=is_incremental()
        ) -%}
    {% endif %}

    {% set new_query_tag = tojson(tag_dict) %}
    {% set original_query_tag = get_current_query_tag() %}
    {{ log("Setting query_tag to '" ~ new_query_tag ~ "'. Will reset to '" ~ original_query_tag ~ "' after materialization.") }}
    {% do run_query("alter session set query_tag = '{}'".format(new_query_tag)) %}
    {{ return(original_query_tag)}}
{% endmacro %}

{% macro unset_query_tag(original_query_tag) -%}
    {{ return(adapter.dispatch('unset_query_tag', 'dbt_snowflake_query_tags')(original_query_tag)) }}
{%- endmacro %}

{% macro default__unset_query_tag(original_query_tag) -%}
    {% if original_query_tag %}
    {{ log("Resetting query_tag to '" ~ original_query_tag ~ "'.") }}
    {% do run_query("alter session set query_tag = '{}'".format(original_query_tag)) %}
    {% else %}
    {{ log("No original query_tag, unsetting parameter.") }}
    {% do run_query("alter session unset query_tag") %}
    {% endif %}
{% endmacro %}
