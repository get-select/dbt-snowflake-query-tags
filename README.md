# dbt-snowflake-query-tags

From the [SELECT](https://select.dev) team, a dbt package to automatically tag dbt-issued queries with informative metadata. Example metadata is:

```json
{
    "dbt_snowflake_query_tags_version": "1.0.0",
    "app": "dbt",
    "dbt_version": "1.4.0",
    "project_name": "my_project",
    "target_name": "dev",
    "target_database": "dev",
    "target_schema": "larry_goldings",
    "invocation_id": "c784c7d0-5c3f-4765-805c-0a377fefcaa0",
    "node_name": "orders",
    "node_alias": "orders",
    "node_package_name": "my_project",
    "node_original_file_path": "models/staging/orders.sql",
    "node_database": "dev",
    "node_schema": "mart",
    "node_id": "model.my_project.orders",
    "node_resource_type": "model",
    "materialized": "incremental",
    "is_incremental": true
}
```

When running in dbt Cloud, this package also adds the following metadata:
```
dbt_cloud_project_id
dbt_cloud_job_id
dbt_cloud_run_id
dbt_cloud_run_reason_category
dbt_cloud_run_reason
```

## Quickstart

1. Add this package to your `packages.yml` file, then install it with `dbt deps`.

```yaml
packages:
  - package: get-select/dbt_snowflake_query_tags
    version: 1.0.0
```

2. If you're running dbt < 1.2 then you'll need to override this using local macros. If it doesn't already exist, create a folder named `macros` in your dbt project's top level directory. Inside, make a new file called `query_tags.sql` with the following content:

```sql
{% macro set_query_tag() -%}
{% do return(dbt_snowflake_query_tags.set_query_tag()) %}
{% endmacro %}

{% macro unset_query_tag(original_query_tag) -%}
{% do return(dbt_snowflake_query_tags.unset_query_tag(original_query_tag)) %}
{% endmacro %}
```

3. If you're running dbt >= 1.2 then you can add dispatching to your `dbt_project.yml`
```yaml
dispatch:
  - macro_namespace: dbt
    search_order:
      - <YOUR_PROJECT_NAME>
      - dbt_snowflake_query_tags
      - dbt
```

That's it! All dbt-issued queries will now be tagged.

## Contributing

### Adding a CHANGELOG Entry
We use changie to generate CHANGELOG entries. Note: Do not edit the CHANGELOG.md directly. Your modifications will be lost.

Follow the steps to [install changie](https://changie.dev/guide/installation/) for your system.

Once changie is installed and your PR is created, simply run `changie new` and changie will walk you through the process of creating a changelog entry. Commit the file that's created and your changelog entry is complete!
