# Pinterest Ads Transformation dbt Package ([Docs](https://fivetran.github.io/dbt_pinterest/))

<p align="left">
    <a alt="License"
        href="https://github.com/fivetran/dbt_pinterest/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_,<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
</p>

## What does this dbt package do?
- Produces modeled tables that leverage Pinterest Ads data from [Fivetran's connector](https://fivetran.com/docs/applications/pinterest-ads) in the format described by [this ERD](https://fivetran.com/docs/applications/pinterest-ads#schemainformation) and builds off the output of our [Pinterest Ads source package](https://github.com/fivetran/dbt_pinterest_source).
- Enables you to better understand the performance of your ads across varying grains:
  - Providing an advertiser, campaign, ad group, keyword, pin, and utm level reports.
- Materializes output models designed to work simultaneously with our [multi-platform Ad Reporting package](https://github.com/fivetran/dbt_ad_reporting).
- Generates a comprehensive data dictionary of your source and modeled Pinterest Ads data through the [dbt docs site](https://fivetran.github.io/dbt_pinterest/).


<!--section=“pinterest_transformation_model"-->

The following table provides a detailed list of all tables materialized within this package by default.
> TIP: See more details about these tables in the package's [dbt docs site](https://fivetran.github.io/dbt_pinterest/#!/overview?g_v=1&g_e=seeds).

| **Table**                | **Description**                                                                                                                                |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| [pinterest_ads__ad_group_report](https://fivetran.github.io/dbt_pinterest/#!/model/model.pinterest.pinterest_ads__ad_group_report)            | Each record in this table represents the daily performance of ads at the campaign, advertiser, and ad group level.|
| [pinterest_ads__advertiser_report](https://fivetran.github.io/dbt_pinterest/#!/model/model.pinterest.pinterest_ads__advertiser_report)             | Each record in this table represents the daily performance at the advertiser level. |
| [pinterest_ads__campaign_report](https://fivetran.github.io/dbt_pinterest/#!/model/model.pinterest.pinterest_ads__campaign_report)            | Each record in this table represents the daily performance of ads at the advertiser and campaign level. |
| [pinterest_ads__campaign_country_report](https://fivetran.github.io/dbt_pinterest/#!/model/model.pinterest.pinterest_ads__campaign_country_report)            | Each record in this table represents the daily performance of ads at the advertiser, campaign, and country level. |
| [pinterest_ads__campaign_region_report](https://fivetran.github.io/dbt_pinterest/#!/model/model.pinterest.pinterest_ads__campaign_region_report)            | Each record in this table represents the daily performance of ads at the advertiser, campaign, and region level. |
| [pinterest_ads__keyword_report](https://fivetran.github.io/dbt_pinterest/#!/model/model.pinterest.pinterest_ads__keyword_report)            | Each record in this table represents the daily performance of a keyword at the advertiser, campaign, ad group, and keyword level. |
| [pinterest_ads__pin_promotion_report](https://fivetran.github.io/dbt_pinterest/#!/model/model.pinterest.pinterest_ads__pin_promotion_report)            | Each record in this table represents the daily performance of ads at the advertiser, campaign, ad group, and pin level. |
| [pinterest_ads__url_report](https://fivetran.github.io/dbt_pinterest/#!/model/model.pinterest.pinterest_ads__url_report)            | Each record in this table represents the daily performance of ads at the advertiser, campaign, ad group, and url level. |

### Materialized Models
Each Quickstart transformation job run materializes 34 models if all components of this data model are enabled. This count includes all staging, intermediate, and final models materialized as `view`, `table`, or `incremental`.
<!--section-end-->

## How do I use the dbt package?

### Step 1: Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Pinterest Ads connection syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.

#### Databricks Dispatch Configuration
If you are using a Databricks destination with this package you will need to add the below (or a variation of the below) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.

```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

### Step 2: Install the package (skip if also using the `ad_reporting` combo package)
Include the following pinterest_ads package version in your `packages.yml` file _if_ you are not also using the upstream [Ad Reporting combination package](https://github.com/fivetran/dbt_ad_reporting):

```yml
packages:
  - package: fivetran/pinterest
    version: [">=0.13.0", "<0.14.0"] # we recommend using ranges to capture non-breaking changes automatically
```

Do NOT include the `pinterest_source` package in this file. The transformation package itself has a dependency on it and will install the source package as well.

### Step 3: Define database and schema variables
By default, this package runs using your destination and the `pinterest` schema. If this is not where your Pinterest Ads data is (for example, if your Pinterest Ads schema is named `pinterest_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
    pinterest_database: your_destination_name
    pinterest_schema: your_schema_name 
```

### Step 4: Enable/disable models and sources
This package takes into consideration that not every Pinterest account tracks `keyword` performance, and allows you to disable the corresponding functionality by adding the following variable configuration:

```yml
vars:
    pinterest__using_keywords: False # Default = true
```

Additionally, your Pinterest Ads connection may not sync every table that this package expects. If you do not have the `PIN_PROMOTION_TARGETING_REPORT`, `TARGETING_GEO`, or `TARGETING_GEO_REGION` tables synced, add the following variable to your root `dbt_project.yml` file:

```yml
vars:
    pinterest__using_pin_promotion_targeting_report: false # Default is true. Will disable `pinterest_ads__campaign_country_report` and `pinterest_ads__campaign_region_report` if false
    pinterest__using_targeting_geo: false # Default is true. Will disable `pinterest_ads__campaign_country_report` if false
    pinterest__using_targeting_geo_region: false # Default is true. Will disable `pinterest_ads__campaign_region_report` if false
```

### (Optional) Step 5: Additional configurations

<details open><summary>Expand/Collapse details</summary>

#### Union multiple connections
If you have multiple pinterest connections in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. The package will union all of the data together and pass the unioned table into the transformations. You will be able to see which source it came from in the `source_relation` column of each model. To use this functionality, you will need to set either the `pinterest_ads_union_schemas` OR `pinterest_ads_union_databases` variables (cannot do both) in your root `dbt_project.yml` file:

```yml
vars:
    pinterest_ads_union_schemas: ['pinterest_usa','pinterest_canada'] # use this if the data is in different schemas/datasets of the same database/project
    pinterest_ads_union_databases: ['pinterest_usa','pinterest_canada'] # use this if the data is in different databases/projects but uses the same schema name
```
> NOTE: The native `source.yml` connection set up in the package will not function when the union schema/database feature is utilized. Although the data will be correctly combined, you will not observe the sources linked to the package models in the Directed Acyclic Graph (DAG). This happens because the package includes only one defined `source.yml`.

To connect your multiple schema/database sources to the package models, follow the steps outlined in the [Union Data Defined Sources Configuration](https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source) section of the Fivetran Utils documentation for the union_data macro. This will ensure a proper configuration and correct visualization of connections in the DAG.

### Passing Through Additional Metrics
By default, this package will select `clicks`, `impressions`, `spend` (converted from `spend_in_micro_dollar`), `total_conversions`, `total_conversions_quantity`, and `total_conversions_value` (converted from `total_conversions_value_in_micro_dollar`) from the source reporting tables to store into the staging models. If you would like to pass through additional metrics to the staging models, add the below configurations to your `dbt_project.yml` file. These variables allow for the pass-through fields to be aliased (`alias`) if desired, but not required. Use the below format for declaring the respective pass-through variables:

> IMPORTANT: Make sure to exercise due diligence when adding metrics to these models. The metrics added by default (clicks, impressions, spend, total conversions, total conversions quantity, and total conversions value) have been vetted by the Fivetran team maintaining this package for accuracy. There are metrics included within the source reports, for example metric averages, which may be inaccurately represented at the grain for reports created in this package. You will want to ensure whichever metrics you pass through are indeed appropriate to aggregate at the respective reporting levels provided in this package.

```yml
vars:
    pinterest__ad_group_report_passthrough_metrics:
      - name: "this_field"
    pinterest__advertiser_report_passthrough_metrics:
      - name: "unique_string_field"
        alias: "field_id"
    pinterest__campaign_report_passthrough_metrics:
      - name: "that_field"
    pinterest__keyword_report_passthrough_metrics:
      - name: "other_id"
        alias: "another_id"
    pinterest__pin_promotion_report_passthrough_metrics: 
      - name: "new_custom_field"
        alias: "custom_field"
    pinterest__pin_promotion_targeting_report_passthrough_metrics:
      - name: "new_field"
```

#### Change the build schema
By default, this package builds the Pinterest Ads staging models (10 views, 10 models) within a schema titled (`<target_schema>` + `_pinterest_source`) and your Pinterest Ads modeling models (6 tables) within a schema titled (`<target_schema>` + `_pinterest`) in your destination. If this is not where you would like your Pinterest Ads data to be written to, add the following configuration to your root `dbt_project.yml` file:

```yml
models:
    pinterest_source:
      +schema: my_new_schema_name # leave blank for just the target_schema
    pinterest:
      +schema: my_new_schema_name # leave blank for just the target_schema
```

#### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable. This is not available when running the package on multiple unioned connections.

> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_pinterest/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
vars:
    pinterest_<default_source_table_name>_identifier: your_table_name 
```

</details>

### (Optional) Step 6: Orchestrate your models with Fivetran Transformations for dbt Core™   
<details><summary>Expand for more details</summary>
<br>

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).

</details>

## Does this package have dependencies?
This dbt package is dependent on the following dbt packages. These dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.

```yml
packages:
    - package: fivetran/pinterest_source
      version: [">=0.13.0", "<0.14.0"]

    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]

    - package: dbt-labs/spark_utils
      version: [">=0.3.0", "<0.4.0"]
```
        
## How is this package maintained and can I contribute?
### Package Maintenance

The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/pinterest/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_pinterest/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Opinionated Decisions
In creating this package, which is meant for a wide range of use cases, we had to take opinionated stances on a few different questions we came across during development. We've consolidated significant choices we made in the [DECISIONLOG.md](https://github.com/fivetran/dbt_pinterest/blob/main/DECISIONLOG.md), and will continue to update as the package evolves. We are always open to and encourage feedback on these choices, and the package in general.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package.

#### Contributors
We thank [everyone](https://github.com/fivetran/dbt_pinterest/graphs/contributors) who has taken the time to contribute. Each PR, bug report, and feature request has made this package better and is truly appreciated.

A special thank you to [Seer Interactive](https://www.seerinteractive.com/?utm_campaign=Fivetran%20%7C%20Models&utm_source=Fivetran&utm_medium=Fivetran%20Documentation), who we closely collaborated with to introduce native conversion support to our Ad packages.

## Are there any resources available?
- If you have questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_pinterest/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
