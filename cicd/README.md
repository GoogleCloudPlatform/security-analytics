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
  -l LOCAL_PATH, --local_path LOCAL_PATH
                        local rules path
  -m, --make_changes    fix any differences, if omitted then just report
                        differences
  -s, --silent          supress error messages
  -r REGION, --region REGION
                        Chronicle instance region (leave blank for US)
```

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

The [`chronicle-rules-cicd.yaml`](./github-actions/chronicle-rules-cicd.yml) file located in the 
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
