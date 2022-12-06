# CI/CD Python Scripts

## Overview

The [`python` folder](./python/) contains Python helper scripts to gather rules from a local folder and from the remote
Chronicle instance, and to compare them, uploading changed or new files to the Chronicle instance.

## Pre-installation

Pre-requisites can be installed by copying the files from the folder locally, and running `pip3 install -r requirements.txt`

To run this script you will need a Chronicle API Service Account JSON file. This can be obtained from your Google Chronicle 
account team.

## Usage

First export the path to your Chronicle API key like this:

```bash
export PATH_TO_KEY=~/malachite-abc-7ba40dd4f123.json
```

Now run the script like this:

```bash
python3 rules.py -c $PATH_TO_KEY -l ../../rules -m
```

The command line arguments are described below:

```
usage: rules.py [-h] -c CREDENTIALS_FILE -l LOCAL_PATH [-m]

optional arguments:
  -h, --help            show this help message and exit
  -c CREDENTIALS_FILE, --credentials_file CREDENTIALS_FILE
                        path to credentials file
  -i CREDENTIALS_INFO, --credentials_info CREDENTIALS_INFO
                        service account credentials info (alternative to file)
  -e CREDENTIALS_ENV, --credentials_env CREDENTIALS_ENV
                        service account credentials info stored in environment
                        variable
  -l LOCAL_PATH, --local_path LOCAL_PATH
                        local rules path
  -m, --make_changes    fix any differences, if omitted then just report
                        differences
  -s, --silent          supress error messages
  -r REGION, --region REGION
                        Chronicle instance region (leave blank for US)
```

NOTE: if you provide more than one of `CREDENTIALS_FILE`, `CREDENTIALS_INFO`, `CREDENTIALS_ENV`, then the 
order of precedence will be file -> info -> environment variable.

Example output from reporting (omitting `-m` flag):

```json
{
  "matched_rules": 6,
  "rules_to_update": 1,
  "non_existent_rules": 2,
  "remote_rules_total": 76,
  "local_rules_total": 9
}
```

Example output from making changes (including `-m` flag):

```json
{
  "rules_uploaded": 1,
  "rules_added": 2
}
```

## Using in a GitHub Actions pipeline

The [`chronicle-rules-cicd.yml`](./github-actions/chronicle-rules-cicd.yml) file located in the 
[`github-actions` folder](./github-actions/) in this repository contains an example of using this 
Python script to push updates or new detection content to a Chronicle instance. There are two variables 
to edit in this script:

Variable Name | Description | Example Value
---|---|---
`region` | The region for your Chronicle instance | us
`rules_path` | The relative path from the root of the repository containing the YARA-L rules to work with | rules/yaral

These should be modified for your environment, and the file should be placed in a `.github/workflow` folder in the root of your
repository.

In addition to this, the pipeline file requires a secret to be created on your GitHub repository. Details for creating this
can be found [here](https://docs.github.com/en/actions/security-guides/encrypted-secrets). The secret in this case should 
be named `SA_CREDENTIAL`. The value is derived from the contents of your Chronicle API key, but line breaks should be 
removed from the file, and the `"` character should also be replaced with `\"`. This can be generated with the following 
command in *nix operating systems:

```bash
cat ~/malachite-abc-7ba40dd4f123.json | tr '\n' ' ' | sed -r 's/\"/\\"/g'
```

The resulting string can then be pasted into the Secrets UI in GitHub.

Now whenever a change is written to the repository the contents of the passed rules folder will be checked and updated/uploaded
on the Chronicle instance.

## Using in a Google Cloud Build pipeline

The [`cloudbuild.yaml`](./cloudbuild/cloudbuild.yaml) file located in the 
[`cloudbuild` folder](./cloudbuild/) in this repository contains an example of using this 
Python script to push updates or new detection content to a Chronicle instance using Google
Cloud Build.

The pipeline file requires a secret to be created in Secrets Manager, and for this to be 
made available to the service account running the build pipeline. Details for creating this
can be found [here](https://cloud.google.com/build/docs/securing-builds/use-secrets). The 
value can be copy/pasted from the contents of your Chronicle API key into the Secrets 
Manager UI or API.

Your repository should be added in Cloud Build, and a trigger created following [this document](https://cloud.google.com/build/docs/automating-builds/create-manage-triggers), 
with the below substitutions added.

There are four user-defined substitutions to create to support this script:

Substitution Name | Description | Example Value
---|---|---
`_REGION` | The region for your Chronicle instance | us
`_RULES_PATH` | The relative path from the root of the repository containing the YARA-L rules to work with | rules/yaral
`_PROJECT_ID` | The project ID containing the secret created earlier | my-project-id
`_SECRET_NAME` | The name of the secret created earlier | bk_api_credential

More detail on substitutions can be found [here](https://cloud.google.com/build/docs/configuring-builds/substitute-variable-values#using_user-defined_substitutions).

The cloudbuild.yaml file should be placed in the root of your repository.

## Using in a Azure DevOps pipeline

The [`azure-pipelines.yml`](./azure-devops/azure-pipelines.yml) file located in the 
[`azure-devops` folder](./azure-devops/) in this repository contains an example of using this 
Python script to push updates or new detection content to a Chronicle instance using Azure DevOps
Pipelines.

There are two variables 
to edit in this script:

Variable Name | Description | Example Value
---|---|---
`region` | The region for your Chronicle instance | us
`rules_path` | The relative path from the root of the repository containing the YARA-L rules to work with | rules/yaral

These should be modified for your environment, and the file should be placed in the root of your repository.

The pool name value should also be updated in the pipelines file, to match the agent pool you want to use to run the code.

In addition to this, the pipeline file requires a secret to be created on your Azure DevOps project. Details for creating this
can be found [here](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/set-secret-variables?view=azure-devops&tabs=yaml%2Cbash). The secret in this case should be named `SA_CREDENTIAL`. The value is the contents of your Chronicle API key, which can just be
copy/pasted into the UI, shown in the linked document above, from the JSON file containing the key.

Now whenever a change is written to the repository the contents of the passed rules folder will be checked and updated/uploaded
on the Chronicle instance.
