import re
import sys
from google.oauth2 import service_account
from google.auth.transport import requests
import base64
from pathlib import Path
import argparse
from typing import Optional
from typing import Sequence
import json

API_BASE_URL='https://backstory.googleapis.com'
SCOPES = ['https://www.googleapis.com/auth/chronicle-backstory']

def get_http_client_from_file(service_account_file):
  # Create a credential using Google Developer Service Account Credential and Chronicle API scope.
  credentials = service_account.Credentials.from_service_account_file(service_account_file, scopes=SCOPES)
  # Build an HTTP client to make authorized OAuth requests.
  return requests.AuthorizedSession(credentials)

def get_http_client_from_sa_info(service_account_info):
  # Create a credential using Google Developer Service Account Credential and Chronicle API scope.
  credentials = service_account.Credentials.from_service_account_info(json.loads(service_account_info), scopes=SCOPES)
  # Build an HTTP client to make authorized OAuth requests.
  return requests.AuthorizedSession(credentials)

def initialize_command_line_args(
    args: Optional[Sequence[str]] = None) -> Optional[argparse.Namespace]:
  """Initializes and checks all the command-line arguments."""
  parser = argparse.ArgumentParser()
  parser.add_argument(
    "-c", "--credentials_file", type=str, help="path to credentials file")
  parser.add_argument(
    "-i", "--credentials_info", type=str, help="service account credentials info (alternative to file)")
  parser.add_argument(
    "-l", "--local_path", type=str, required=True, help="local rules path")
  parser.add_argument(
    "-m", "--make_changes", action='store_true',  help="fix any differences, if omitted then just report differences" )
  parser.add_argument(
    "-s", "--silent", action='store_true',  help="supress error messages" )
  parser.add_argument(
    "-r", "--region", required=False, default="us", choices=("asia-southeast1", "europe", "us"), help="Chronicle instance region (leave blank for US)" )
    
  parser.set_defaults(make_changes=False)
  return parser.parse_args(args)

def get_all_rules(session):
  try:
    rules_response = []
    url=f'{API_BASE_URL}/v2/detect/rules'
    response = session.request(
      method="GET",
      url=url,
    )
    if response.json():
      rules_array = response.json()
      for rule in rules_array['rules']:
        rules_response.append({
          'name': rule['ruleName'],
          'rule_id': rule['ruleId'],
          'text': base64.b64encode(rule['ruleText'].strip().encode('utf-8')).decode('utf-8'),
          'text_raw': rule['ruleText'].strip(),
        })
    return rules_response
  except:
    print(f'Received error code: {response.status_code}')

def load_local_files(path):
  rules_response = []
  file_list = list(Path(path).rglob("*.[yY][aA][rR][aA][lL]"))
  for file in file_list:
    file_content = open(file, "r").read()
    rules_response.append({
      'name': parse_rule_name(file_content), #str(file.stem),
      'path': str(file),
      'text': base64.b64encode(file_content.strip().encode('utf-8')).decode('utf-8'),
      'text_raw': file_content.strip(),
    })
  return rules_response

def parse_rule_name(rule_text):
  rule_name = re.search("rule ([A-Za-z0-9_]+)[\r\n\s]?{", rule_text)
  if rule_name:
    return rule_name.group(1)
  else:
    return False

def compare_rules(session, local_rules_path, silent=False):
  count_non_existent_rules = 0
  count_matched_rules = 0
  count_rules_to_update = 0
  local_rules = load_local_files(local_rules_path)
  remote_rules = get_all_rules(session)
  for local_rule in local_rules:
    if remote_rules:
      matched_remote_rules = [x for x in remote_rules if x['name'] == local_rule['name']]
      if len(matched_remote_rules) > 0:
        if len(matched_remote_rules) != 1:
          print(f'Matched rules was not equal to 1 for {local_rule["name"]}')
        else:
          if matched_remote_rules[0]['text'] == local_rule['text']:
            count_matched_rules += 1
          else:
            count_rules_to_update += 1
      else:
        count_non_existent_rules += 1
    else:
      count_non_existent_rules += 1
  if remote_rules:
    count_remote_rules = len(remote_rules)
  else: 
    count_remote_rules = 0
  if local_rules:
    count_local_rules = len(local_rules)
  else:
    count_local_rules = 0
  return {
    "matched_rules": count_matched_rules,
    "rules_to_update": count_rules_to_update,
    "non_existent_rules": count_non_existent_rules,
    "remote_rules_total": count_remote_rules,
    "local_rules_total": count_local_rules,
  }

def upload_missing_rules(session, local_rules_path, silent=False):
  rules_updated = 0
  rules_added = 0
  error_count = 0
  errors = []
  local_rules = load_local_files(local_rules_path)
  remote_rules = get_all_rules(session)
  for local_rule in local_rules:
    if local_rule['name']:
      matched_remote_rules = [x for x in remote_rules if x['name'] == local_rule['name']]
      if len(matched_remote_rules) > 0:
        if len(matched_remote_rules) != 1:
          print(f'upload_missing_rules / Matched rules was not equal to 1 for {local_rule["name"]}')
        else:
          try:
            if matched_remote_rules[0]['text'] != local_rule['text']:
              if update_rule(session,local_rule['text_raw'],matched_remote_rules[0]['rule_id'],local_rule['name'], silent):
                rules_updated += 1
              else:
                error_count += 1
          except:
            if not silent: print(f"upload_missing_rules / Update of rule {local_rule['name']} failed")
            errors.append(f"upload_missing_rules / Update of rule {local_rule['name']} failed")
            error_count += 1
      else:
        try:
          if create_rule(session,local_rule['text_raw'],local_rule['name'],silent):
            rules_added += 1
          else:
            error_count += 1
        except:
          if not silent: print(f"upload_missing_rules / Creation of rule {local_rule['name']} failed")
          errors.append(f"upload_missing_rules / Creation of rule {local_rule['name']} failed")
          error_count += 1
    else:
      if not silent: print(f"upload_missing_rules / rule with path {local_rule['path']} has an issue")
      errors.append(f"upload_missing_rules / Creation of rule {local_rule['path']} failed")
      error_count += 1

  return {
    "rules_added": rules_added,
    "rules_updated": rules_updated,
    "errors": error_count,
    "error_details": errors,
  }

def verify_rule(session,rule_text,rule_name,silent=False):
  try:
    url=f'{API_BASE_URL}/v2/detect/rules:verifyRule'
    body={"rule_text":rule_text}
    response = session.request(
      method="POST",
      url=url,
      json=body
    )
    response.raise_for_status()
    return True
  except:
    if not silent: print(f'verify_rule [{rule_name}]/ Received error code: {response.status_code}')
    return False


def create_rule(session,rule_text,rule_name, silent=False):
  if verify_rule(session,rule_text,rule_name,silent):
    try:
      url=f'{API_BASE_URL}/v2/detect/rules'
      body={"rule_text":rule_text}
      response = session.request(
        method="POST",
        url=url,
        json=body
      )
      response.raise_for_status()
      return True
    except:
      if not silent: print(f'create_rule / Received error code: {response.status_code}')
      return False
  else:
    return False

def update_rule(session,rule_text,rule_id,rule_name,silent=False):
  if verify_rule(session,rule_text,rule_name,silent):
    try:
      url=f'{API_BASE_URL}/v2/detect/rules/{rule_id}:createVersion'
      body={"ruleText":rule_text}
      response = session.request(
        method="POST",
        url=url,
        json=body
      )
      response.raise_for_status()
      return True
    except:
      if not silent: print(f'update_rule / Received error code: {response.status_code}')
      return False
  else:
    return False

if __name__ == "__main__":
  cli = initialize_command_line_args()
  if not cli:
    sys.exit(1)  # A sanity check failed.
  if not cli.region == "us":
    API_BASE_URL=f'https://{cli.region}-backstory.googleapis.com'
  if cli.credentials_file:
    session = get_http_client_from_file(cli.credentials_file)
  elif cli.credentials_info:
    session = get_http_client_from_sa_info(cli.credentials_info)
  else:
    print("No credential passed")
  if not cli.make_changes:
    print(json.dumps(compare_rules(session,cli.local_path, cli.silent),indent=2))
  else:
    print(json.dumps(upload_missing_rules(session,cli.local_path, cli.silent),indent=2))