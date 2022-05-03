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
 log_name,
 proto_payload.audit_log.authentication_info.principal_email,
 proto_payload.audit_log.method_name,
 proto_payload.audit_log.resource_name,
 bindingDelta
FROM
 `[MY_PROJECT_ID].[MY_DATASET_ID]._AllLogs`,
  UNNEST(JSON_QUERY_ARRAY(proto_payload.audit_log.service_data.policyDelta.bindingDeltas)) AS bindingDelta
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 180 DAY)
  AND resource.type = "service_account"
  AND proto_payload.audit_log.method_name LIKE "google.iam.admin.%.SetIAMPolicy"
  AND JSON_VALUE(bindingDelta.action) = 'ADD'
  AND JSON_VALUE(bindingDelta.role) IN (
    'roles/iam.serviceAccountKeyAdmin'
  )