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
  timestamp,
  proto_payload.audit_log.authentication_info.principal_email as grantor,
  JSON_VALUE(bindingDelta.member) as grantee,
  JSON_VALUE(bindingDelta.role) as role,
  proto_payload.audit_log.resource_name,
  proto_payload.audit_log.method_name
FROM
  `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`,
  UNNEST(JSON_QUERY_ARRAY(proto_payload.audit_log.service_data.policyDelta.bindingDeltas)) AS bindingDelta
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 180 DAY)
  -- AND log_id = "cloudaudit.googleapis.com/activity"
  AND (
    (resource.type = "service_account"
    AND proto_payload.audit_log.method_name LIKE "google.iam.admin.%.SetIAMPolicy")
    OR
    (resource.type IN ("project", "folder", "organization")
    AND proto_payload.audit_log.method_name = "SetIamPolicy")
  )
  AND JSON_VALUE(bindingDelta.role) IN (
    'roles/iam.serviceAccountTokenCreator',
    'roles/iam.serviceAccountUser'
  )
  AND JSON_VALUE(bindingDelta.action) = 'ADD'
  -- Principal (grantee) exclusions
  AND JSON_VALUE(bindingDelta.member) NOT LIKE "%@example.com"
ORDER BY
  timestamp DESC
