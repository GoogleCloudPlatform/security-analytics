# How to Contribute

We'd love to accept your patches and contributions to this project. There are
just a few small guidelines you need to follow.

## Contributor License Agreement

Contributions to this project must be accompanied by a Contributor License
Agreement. You (or your employer) retain the copyright to your contribution;
this simply gives us permission to use and redistribute your contributions as
part of the project. Head over to <https://cla.developers.google.com/> to see
your current agreements on file or to sign a new one.

You generally only need to submit a CLA once, so if you've already submitted one
(even if it was for a different project), you probably don't need to do it
again.

## Adding CSA Content

### New Security Question
To add a new threat detection or audit question, follow these steps:

1. Determine ID for the new security question, as described in [CSA Identification](#csa-identification) section below. For the remainder of this section, we'll assume the new CSA ID to be added is `5.40`.

2. Create a new folder under `src` for that new CSA:
    ```
    mkdir src/5.40
    ```
3. Copy CSA sample definition [`sample.yaml`](./sample.yaml) into this new folder, and rename it to match CSA ID:
    ```
    cp ./sample.yaml src/5.40/5.40.yaml
    ```
4. Edit new CSA definition file (in this case `5.40.yaml`) with details of the new CSA use case including description, category, log source(s), MITRE ATT&CK mapping(s), test steps and log samples if any. Refer to sample YAML file for reference of YAML attributes and expected values format.

5. Generate CSA docs, as described in [Doc Generation](#doc-generation) section below. This will create a new individual CSA doc `src/5.40/5.40.md` and an updated root `README.md` based on the new CSA definition, that is source file `src/5.40/5.40.yaml`.

3. Submit PR with new CSA files (e.g. `src/5.40/*`) and updated `README.md` file.

### New Query Implementation
To implement a `SQL` query or `YARA-L` rule for an existing or new security question, follow the steps in this section. We'll assume the CSA in question has ID `5.40` and name `sql_tables_most_frequently_accessed`.

1. To provide a BigQuery SQL query, implement query in a new SQL file under `backends/bigquery/sql/` folder, named after corresponding CSA ID and name, which is in our example `5_40_sql_tables_most_frequently_accessed.sql`.

1. To provide a Log Analytics SQL query, implement query in a new SQL file under `backends/log_analytics/sql/` folder, named after corresponding CSA ID and name, which is in our example `5_40_sql_tables_most_frequently_accessed.sql`.

2. To add a Google SecOps YARA-L rule, implement rule in a new YARA-L file under `backends/chronicle/yaral/` folder, named after corresponding CSA ID and name, which is in our example
`5_40_sql_tables_most_frequently_accessed.yaral` .

CSA design favors **convention over configuration** when it comes to file naming and docs generation. Therefore, special attention is required for query/rule file naming where the new filename must match a specific format per above examples, where:
- CSA ID and name are concatenated, and
- CSA ID `.` (dot) separator is replaced with `_` (underscore)

Once a query is implemented, re-generate CSA docs as described in [Doc Generation](#doc-generation) section below. This will update the individual CSA doc (in our example `src/5.40/5.40.md`) with links to corresponding query file(s) as shown in screenshot below. If the corresponding query file is not found (either because it doesn't exist yet or has incorrect filename format), the placeholder defaults to call to action `Contribute...` with a link to this CONTRIBUTING.md file.

![Query link in auto-generated CSA doc](/assets/csa_doc_query.png)

## CSA Identification

Every CSA use case or question has a unique ID to uniquely identify it. A CSA use case ID, or for short a CSA ID, is of the form `A.B` where:

-  A is a 1-digit bumber from the set [1-6]. A specifies the category ID, per the following mapping:
    ```
    1: Login & Access Patterns
    2: IAM, Keys & Secrets Admin Activity
    3: Cloud Provisoning Activity
    4: Cloud Workload Usage
    5: Data Usage
    6: Network Activity
    ```

-  B is a 2-digit number from the set [01-99]. B is a continously increasing number which specifies the question ID within category A.

For example, [CSA `1.01`](./src/1.01/1.01.md), is the first security question from category #1. Consider you're adding a new security question for category 5, then the ID is `5.B` where B is the next available number in that category. In this example, we'll use `5.40`.

## Doc Generation

The [CSA index](./README.md#security-analytics-use-cases) in README.md as well as individual CSA use case documentation (e.g. [CSA `1.01`](./src/1.01/1.01.md)) are automatically generated based on:
- YAML spec files under `src/` , and,
- Corresponding log samples under `test/fixtures/` folder, and,
- Corresponding query implementations under `backends/*/sql/` and `backends/*/yaral/` folders.

After adding or editing files under any of these directories, here are the steps to regenerate the docs to reflect the changes:

1. Rebuild `index.md` and individual CSA docs `src/*/*.md` as follows:
    ```
    ./bin/generate-docs.rb
    ```
2. Copy/paste `index.md` content into [CSA index](./README.md#security-analytics-use-cases) section in `README.md`

3. Preview to validate new (or updated) CSA use case docs `src/*/*.md` and the updated root `README.md` doc.

## Code Reviews

All submissions, including submissions by project members, require review. We
use GitHub pull requests for this purpose. Consult
[GitHub Help](https://help.github.com/articles/about-pull-requests/) for more
information on using pull requests.

## Community Guidelines

This project follows [Google's Open Source Community
Guidelines](https://opensource.google/conduct/).