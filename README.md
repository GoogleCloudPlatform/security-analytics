# Dataform for CSA

## Overview

This Dataform repo is provided to automate deployment of all CSA queries and underlying tables in BigQuery, while optimizing for query run-time performance and cost (data volume scanned). This Dataform project is targetted for customers using CSA queries for Log Analytics which is powered by BigQuery. Dataform is a service and an open-source data modeling framework to manage ELT process for your data. This particular Dataform project builds:

- Summary tables incremented on a daily or hourly basis.
- Lookup tables refreshed on daily or hourly basis (e.g. IP addresses with first and last seen).
- Intermediary stats tables incremented on a daily basis (e.g. activity count average and stddev per user over a rolling window).
- Report views for daily reporting based on summary tables, plus stats tables when applicable.
- Alert queries for continuous alerting based on raw logs, plus lookup tables when applicable.
- Workflow configurations to update above summary tables, lookups and stats tables on a daily, hourly or your own custom schedule.

To learn more about Dataform, see [Overview of Dataform](https://cloud.google.com/dataform/docs/overview).

See [Getting Started](#getting-started) further below to deploy CSA with Dataform using either your local workstation or a hosted Dataform repository.

## Prerequisite
Before you begin, you must have a linked BigQuery dataset with the `_AllLogs` view provided by Log Analytics. This view is the source data for all the tables and views that will be built by this Dataform. If you haven't already, make sure to:

1. [Route your logs to single log bucket destination](https://cloud.google.com/architecture/security-log-analytics#create_an_aggregated_log_sink)
1. [Upgrade your log bucket to use Log Analytics](https://cloud.google.com/logging/docs/buckets#upgrade-bucket)
1. [Create a linked BigQuery dataset](https://cloud.google.com/logging/docs/buckets#link-bq-dataset)

For details about the general workflow to enable and aggregate logs in Google Cloud, see [Security log analytics workflow](https://cloud.google.com/architecture/security-log-analytics#security_log_analytics_workflow) as part of Google Cloud Architecture Center.

## Configuration

Dataform configuration is controlled by values in [`dataform.json`](./dataform.json) file, in particular the destination Google Cloud project (`defaultDatabase`), the destination BigQuery dataset (`defaultSchema`) and location (`defaultLocation`), and the custom variables listed in following section.

### Variables

| Variable | Description | Default value |
|---|---|---|
| `logs_export_project` | Project where logs are exported, i.e. source project | |
| `logs_export_dataset` | BigQuery dataset where logs are exported, i.e. source dataset. Enter your BigQuery linked dataset of your Log Analytics-enabled log bucket | |
| `raw_lookback_days` | Lookback window for reports from raw data in number of days | 90 |
| `summary_lookback_days` | Lookback window for creating summary tables from raw data in number of days | 90 |
| `report_interval_days` | Report time interval in number of days | 30 |
| `alert_interval_minutes` | Alert time interval in number of minutes | 60 |

## Datasets

### Source datasets

- `definitions/sources/log_source.sqlx` or `_AllLogs`: Default view of all logs in the BigQuery linked dataset of your Log Analytics-enabled log bucket. The full view ID used in the source declaration is `<logs_export_project>.<logs_export_dataset>._AllLogs`.

### Destination datasets
- `defintions/summary/csa_<CSA_ID>_summary_[hourly|daily].sqlx`: **Summary table** for a given CSA ID#. Depending on the use case, summary table are incremented hourly (e.g. network logs) or daily (e.g. admin activity logs). While configurable, the default summarization interval depends on the log volume to be summarized and the desired reporting granularity. For example, VPC flow logs are voluminous and typically reported on hourly basis for tracking traffic volume or number of connections, e.g. `csa_6_01_summary_hourly.sqlx` and `csa_6_15_summary_hourly.sqlx`.
- `defintions/summary/csa_<CSA_ID>_<entity>_lookup.sqlx`: **Lookup table** for a given CSA ID# and a particular entity such as IP addresses (`ips`) or users (`users`). Lookup tables track historical entity information such as IP addresses and when they were first time and last time seen, to be used for threat reporting and alerting. For example, `csa_5_31_ips_lookup` tracks all IP addresses that have accessed any Cloud Storage object. This lookup `csa_5_31_ips_lookup` is used by `csa_5_31_alert` to flag any new connection from a never-before-seen IP address to a sensitive Cloud Storage object.
- `definitions/reports/csa_<CSA_ID>_report.sqlx`: **Report view** for a given CSA ID# based on corresponding summary table, plus lookup table(s) when applicable. This applies to CSA auditing, investigation and reporting use cases.
- `definitions/alerts/csa_<CSA_ID>_alert.sqlx`: **Alert view** for a given CSA ID# based on raw logs, plus lookup table(s) when applicable. This applies to CSA threat detections use cases.
- `definitions/raw/csa_<CSA_ID>_raw.sqlx`: **Raw view** for a given CSA ID# based on raw logs. This view is equivalent to the original Log Analytics SQL query except for the variable `raw_lookback_days` lookback window. Raw views are disabled by default, and available for testing purposes by comparing its query results with the corresponding (optimized) query or alert view.

### Dependency tree

The following shows a section of a compiled graph with all CSA tables and views in the target BigQuery dataset along with their dependencies all the way upstream to the source, that is `_AllLogs` view from the source BigQuery linked dataset.

![Compiled Dataform graph](../assets/csa_dataform_graph.png)


## Getting started

There are two ways to get started:
- [Using local workstation for manual Dataform deployments](#using-local-workstation-manual-deployment)
- [Using Dataform repository for manual or continuous Dataform deployments](#using-dataform-repository-continuous-deployment)

You may want to use your **local workstation** to quickly get started with executing SQLX using only Dataform CLI and a locally cloned copy of this repo. This is particularly suited for CSA developers who prefer to use their favorite IDEs and terminal, and are looking for one-time or ad hoc Dataform executions for **development, testing or prototyping** purposes.

You would want to use the hosted **Dataform repository** to allow you not only to execute SQLX but also to schedule regular Dataform executions to keep these datasets up-to-date with latest logs. This is done using Dataform workflow configurations as documented below. This is particularly suited for CSA operators who need to run continuous Dataform executions for **testing and production** purposes.

## Using local workstation (manual deployment)

### Install Dataform CLI

* In your favorite terminal, run the following command to install Dataform CLI:

        npm i -g @dataform/cli@^2.3.2

### Update Dataform

* Run the following command to CD into `dataform` project directory and update the Dataform framework:

        cd dataform
        npm i @dataform/core@^2.3.2

### Create a credentials file

To connect to your BigQuery warehouse and deploy datasets, Dataform requires a credentials file.

1. Run the following command:

        dataform init-creds bigquery

1. Follow the `init-creds` prompts that walks you through creating the credentials file `.df-credentials.json`

Warning: Do not accidentally commit that file to your repository. The repo `.gitignore` is configured to ignore the credentials file `.df-credentials.json` to help protect your access credentials.

### Override dataform.json

You specify your source and target BigQuery datasets using `dataform.json` file. You can also override any other configuration variables defined in [variables section](#variables).

1. Open `dataform.json` using your favorite editor.
1. Replace `[PROJECT_ID]` placeholder value for `defaultDatabase` with the ID of your Google Cloud Project containing your target BigQuery dataset.
1. Replace `csa` default value for `defaultSchema` with the name of your target BigQuery dataset.
1. Replace `[LOGS_PROJECT_ID]` placeholder value for `logs_export_project` variable, with the ID of the Google Cloud Project where raw logs currently reside.
1. Replace `[LOGS_DATASET_ID]` placeholder value for `logs_export_dataset` variable, with the name of your source BigQuery dataset, i.e. the BigQuery linked dataset where raw logs are stored.

### Compile Dataform code

* To compile all .SQLX code without deploying datasets, run the following command

        dataform compile

For more details on common `dataform compile` command line options, refer to [View compilation output](https://cloud.google.com/dataform/docs/use-dataform-cli#view_compilation_output)

### Execute Dataform code

* To execute all .SQLX code and deploy or update all datasets in your target BigQuery dataset, run the following command:

        dataform run

For more details on common `dataform run` command line options, refer to [Execute code](https://cloud.google.com/dataform/docs/use-dataform-cli#execute_code)

## Using Dataform repository (continuous deployment)

### Create and configure your Dataform respository
Use Cloud Console to create a [Dataform repository](https://cloud.google.com/dataform/docs/repositories). You will need to copy the contents of this CSA dataform folder and host it in your own Git repository to which you would [connect your Dataform repository](https://cloud.google.com/dataform/docs/connect-repository). You can then use the inline editor in Dataform UI to override `dataform.json` settings listed in the [configuration section](#configuration) above. The automated workflows you deploy in this section will compile and execute Dataform on a scheduled basis in your Dataform repository (instead of your local workstation). 

### Schedule executions using Workflows and Cloud Scheduler

The [`daily-workflow.yaml`](./workflows/daily-workflow.yaml) and [`hourly-workflow.yaml`](./workflows/hourly-workflow.yaml) files located in the 
[`workflows`](./workflows/) folder in this repository contain an example of using [Workflows](https://cloud.google.com/workflows) to execute the .SQLX code on a schedule. This is required to incrementally update the daily and hourly summary tables and their respective dependencies such as lookups and stats tables.

1. [Create a service account](https://cloud.google.com/iam/docs/service-accounts-create#creating) and grant it the following roles:

    - `Dataform Editor` so that it can access the Dataform repository, compile it, and invoke Dataform workflows in that repository.
    - `Workflows Invoker` so that it can trigger the Workflows workflows defined in [`daily-workflow.yaml`](./workflows/daily-workflow.yaml) and [`hourly-workflow.yaml`](./workflows/hourly-workflow.yaml) YAML files.

1. Cd into the [`workflows`](./workflows/) folder using `cd workflows`.
1. Open the YAML files in your favorite editor, and replace `[PROJECT_ID]` placeholder value for with the ID of your Google Cloud project containing the Dataform repository, as well as `[REGION]` and `[REPOSITORY]` with the location and name of the repository.

1. Deploy both workflows using the following `gcloud` commands:
    ```bash
    gcloud workflows deploy security-analytics-daily \
    --source=daily-workflow.yaml \
    --service-account=<SERVICE_ACCOUNT>@<PROJECT_ID>.iam.gserviceaccount.com 

    gcloud workflows deploy security-analytics-hourly \
    --source=hourly-workflow.yaml \
    --service-account=<SERVICE_ACCOUNT>@<PROJECT_ID>.iam.gserviceaccount.com
    ```

    Replace the following:

    - `<SERVICE_ACCOUNT>`: the name of the service account created in step 1
    - `<PROJECT_ID>`: the ID of your Google Cloud project

 1. Deploy the scheduling tasks using 
    ```bash
    gcloud scheduler jobs create http security-analytics-daily \
    --schedule='0 0 * * *' \
    --uri=https://workflowexecutions.googleapis.com/v1/projects/<PROJECT_ID>/locations/<REGION>/workflows/security-analytics-daily/executions \
    --oauth-service-account-email=<SERVICE_ACCOUNT>@<PROJECT_ID>.iam.gserviceaccount.com

    gcloud scheduler jobs create http security-analytics-houry \
    --schedule='0 * * * *' \
    --uri=https://workflowexecutions.googleapis.com/v1/projects/<PROJECT_ID>/locations/<REGION>/workflows/security-analytics-hourly/executions \
    --oauth-service-account-email=<SERVICE_ACCOUNT>@<PROJECT_ID>.iam.gserviceaccount.com

    ```

    Replace the following:

    - `<SERVICE_ACCOUNT>`: the name of the service account created in step 1
    - `<PROJECT_ID>`: the ID of your Google Cloud project
    - `<REGION>`: the location of your Dataform repository e.g. 'us-central1'

### Congratulations!

You have now set up two scheduled workflows to continously and incrementally update your datasets in order to keep your reports and views current:

- **security-analytics-daily**: which runs every day at 12:00 AM UTC to update all daily summary tables and their dependencies (e.g. lookup and stats).
- **security-analytics-hourly**: which runs every hour at minute 0 to update all hourly summary tables and their dependencies (e.g. lookup and stats).

See [schedule executions with Workflows and Cloud Scheduler](https://cloud.google.com/dataform/docs/schedule-executions-workflows) in Dataform docs for more information.

Note: you can alternatively [schedule executions with Dataform workflow configurations](https://cloud.google.com/dataform/docs/workflow-configurations) using Cloud Console. You would set up two Dataform workflow configurations to deploy the two sets of SQL workflow actions for CSA: hourly and daily executions. However, the Workflows-based method used above is preferred since it provides:
- Flexibility in designing your orchestration using Workflows steps. For example, in our case, there is an explicit step to first compile the Dataform repository before executing the Dataform workflow using that latest compilation result.
- Easy integration with your existing CI/CD pipelines and Infrastructure-as-Code (IaC) given Workflows' declarative YAML file defintion and the fact it [can be deployed via Terraform](https://registry.terraform.io/modules/GoogleCloudPlatform/cloud-workflows/google/latest).