# dbt-snowflake-query-tags

From the [SELECT](https://select.dev) team, a dbt package to automatically tag dbt-issued queries with informative metadata. This package uses both query comments and query tagging.

An example query comment contains:

```json
{
    "dbt_snowflake_query_tags_version": "2.3.1",
    "app": "dbt",
    "dbt_version": "1.4.0",
    "project_name": "my_project",
    "target_name": "dev",
    "target_database": "dev",
    "target_schema": "dev",
    "invocation_id": "4ffa20a1-5d90-4a27-a58a-553bb6890f25",
    "node_refs": [
        "model_b",
        "model_c"
    ],
    "node_name": "model_a",
    "node_alias": "model_a",
    "node_package_name": "my_project",
    "node_original_file_path": "models/model_a.sql",
    "node_database": "dev",
    "node_schema": "dev",
    "node_id": "model.my_project.model_a",
    "node_resource_type": "model",
    "node_tags": ["tag_1", "tag_2"],
    "node_meta": {"owner": "@alice", "model_maturity": "in dev"},
    "materialized": "incremental",
    "full_refresh": false,
    "which": "run"

    -- dbt Cloud only
    "dbt_cloud_project_id": "146126",
    "dbt_cloud_job_id": "184124",
    "dbt_cloud_run_id": "107122910",
    "dbt_cloud_run_reason_category": "other",
    "dbt_cloud_run_reason": "Kicked off from UI by niall@select.dev",
}
```

Query tags are used solely for attaching the `is_incremental` flag, as this isn't available to the query comment:

```json
{
    "dbt_snowflake_query_tags_version": "2.3.1",
    "app": "dbt",
    "is_incremental": true
}
```

## Quickstart

1. Add this package to your `packages.yml` file, then install it with `dbt deps`.

```yaml
packages:
  - package: get-select/dbt_snowflake_query_tags
    version: [">=2.0.0", "<3.0.0"]
```

2. Adding the query tags

Option 1: If running dbt < 1.2, create a folder named `macros` in your dbt project's top level directory (if it doesn't exist). Inside, make a new file called `query_tags.sql` with the following content:

```sql
{% macro set_query_tag() -%}
{% do return(dbt_snowflake_query_tags.set_query_tag()) %}
{% endmacro %}

{% macro unset_query_tag(original_query_tag) -%}
{% do return(dbt_snowflake_query_tags.unset_query_tag(original_query_tag)) %}
{% endmacro %}
```

Option 2: If running dbt >= 1.2, simply configure the dispatch search order in `dbt_project.yml`.

```yaml
dispatch:
  - macro_namespace: dbt
    search_order:
      - <YOUR_PROJECT_NAME>
      - dbt_snowflake_query_tags
      - dbt
```

3. To configure the query comments, add the following config to `dbt_project.yml`.

```yaml
query-comment:
  comment: '{{ dbt_snowflake_query_tags.get_query_comment(node) }}'
  append: true # Snowflake removes prefixed comments.
```

That's it! All dbt-issued queries will now be tagged.

## Adding additional metadata

### Query comments

To extend the information added in the query comments, use [meta](https://docs.getdbt.com/reference/resource-configs/meta) or [tag](https://docs.getdbt.com/reference/resource-configs/tags) configs. These are automatically added to the query comments.

### Query tags

To extend the information added in the query tags, set the [query_tag](https://docs.getdbt.com/reference/resource-configs/snowflake-configs#query-tags) config value to a mapping type. Examples:

#### Compatible config

Model
```sql
{{ config(
    query_tag = {'team': 'data'}
) }}

select ...
```

Results in a final query tag of
```
'{"team": "data", "app": "dbt", "dbt_snowflake_query_tags_version": "2.3.1", "is_incremental": true}'
```

the additional information is added by this package.

#### Incompatible config

Using a non-mapping type in the `query_tag` config will result in a warning, and the config being ignored.

Model
```sql
{{ config(
    query_tag = 'data team'
) }}

select ...
```

Leads to a warning
```
dbt-snowflake-query-tags warning: the query_tag config value of 'data team' is not a mapping type, so is being ignored. If you'd like to add additional query tag information, use a mapping type instead, or remove it to avoid this message.
```

Results in a final query tag of
```
'{"app": "dbt", "dbt_snowflake_query_tags_version": "2.3.1", "is_incremental": false}'
```

Note that the query_tag value of 'data team' is not present.

## Contributing

### Adding a CHANGELOG Entry
We use changie to generate CHANGELOG entries. Note: Do not edit the CHANGELOG.md directly. Your modifications will be lost.

Follow the steps to [install changie](https://changie.dev/guide/installation/) for your system.

Once changie is installed and your PR is created, simply run `changie new` and changie will walk you through the process of creating a changelog entry. Commit the file that's created and your changelog entry is complete!
