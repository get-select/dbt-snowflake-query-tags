{% macro set_query_tag() -%}
    {{ return(adapter.dispatch('set_query_tag', 'dbt_snowflake_query_tags')()) }}
{%- endmacro %}

{% macro default__set_query_tag() -%}
    {# Get session level query tag #}
    {% set original_query_tag = get_current_query_tag() %}
    {% set original_query_tag_parsed = {} %}

    {% if original_query_tag %}
        {% if fromjson(original_query_tag) is mapping %}
            {% set original_query_tag_parsed = fromjson(original_query_tag) %}
        {% endif %}
    {% endif %}

    {# The env_vars_to_query_tag_list should contain an environment variables list to construct query tag dict #}
    {% set env_var_query_tags = {} %}
    {% if var('env_vars_to_query_tag_list', '') %} {# Get a list of env vars from env_vars_to_query_tag_list variable to add additional query tags #}
        {% for k in var('env_vars_to_query_tag_list') %}
            {% set v = env_var(k, '') %}
            {% do env_var_query_tags.update({k.lower(): v}) if v %}
        {% endfor %}
    {% endif %}

    {# Start with any model-configured dict #}
    {% set query_tag = config.get('query_tag', default={}) %}

    {% if query_tag is not mapping %}
    {% do log("dbt-snowflake-query-tags warning: the query_tag config value of '{}' is not a mapping type, so is being ignored. If you'd like to add additional query tag information, use a mapping type instead, or remove it to avoid this message.".format(query_tag), True) %}
    {% set query_tag = {} %} {# If the user has set the query tag config as a non mapping type, start fresh #}
    {% endif %}

    {% do query_tag.update(original_query_tag_parsed) %}
    {% do query_tag.update(env_var_query_tags) %}

    {%- do query_tag.update(
        app='dbt',
        dbt_snowflake_query_tags_version='2.3.3',
    ) -%}

    {% if thread_id %}
        {%- do query_tag.update(
            thread_id=thread_id
        ) -%}
    {% endif %}


    {# We have to bring is_incremental through here because its not available in the comment context #}
    {% if model.resource_type == 'model' %}
        {%- do query_tag.update(
            is_incremental=is_incremental()
        ) -%}
    {% endif %}

    {% set query_tag_json = tojson(query_tag) %}
    {{ log("Setting query_tag to '" ~ query_tag_json ~ "'. Will reset to '" ~ original_query_tag ~ "' after materialization.") }}
    {% do run_query("alter session set query_tag = '{}'".format(query_tag_json)) %}
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
