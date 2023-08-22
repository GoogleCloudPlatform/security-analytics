/*
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

SELECT
  MAX(timestamp) as last_seen,
  MIN(timestamp) as first_seen,
  proto_payload.audit_log.authentication_info.principal_email as user,
  CASE
    WHEN proto_payload.audit_log.request_metadata.caller_supplied_user_agent LIKE "Mozilla/%" THEN 'Cloud Console'
    WHEN proto_payload.audit_log.request_metadata.caller_supplied_user_agent LIKE "google-cloud-sdk gcloud/%" THEN 'gcloud CLI'
    WHEN proto_payload.audit_log.request_metadata.caller_supplied_user_agent LIKE "google-api-go-client/% Terraform/%" THEN 'Terraform'
    ELSE 'Other'
  END AS channel,
  proto_payload.audit_log.request_metadata.caller_supplied_user_agent as user_agent,
  proto_payload.audit_log.request_metadata.caller_ip as ip,
FROM `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
  AND log_id = "cloudaudit.googleapis.com/data_access"
  AND proto_payload.audit_log.service_name = "cloudresourcemanager.googleapis.com"
  AND proto_payload.audit_log.method_name IN ("GetProject", "FindOrCreateOrganization")
GROUP BY
  user, user_agent, ip
HAVING
  channel = 'Cloud Console'
ORDER BY
  last_seen DESC
