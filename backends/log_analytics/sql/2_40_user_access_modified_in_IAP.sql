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
  proto_payload.audit_log.authentication_info.principal_email,
  resource.type,
  proto_payload.audit_log.resource_name,
  JSON_VALUE(binding, '$.role') as role,
  JSON_VALUE_ARRAY(binding, '$.members') as members
FROM
  `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`,
  UNNEST(JSON_QUERY_ARRAY(proto_payload.audit_log.response, '$.bindings')) AS binding
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
  -- AND log_id = "cloudaudit.googleapis.com/activity"
  AND proto_payload.audit_log.service_name = "iap.googleapis.com"
  AND proto_payload.audit_log.method_name LIKE "%.IdentityAwareProxyAdminService.SetIamPolicy"
  AND JSON_VALUE(binding, '$.role') = "roles/iap.httpsResourceAccessor"
ORDER BY
  timestamp DESC
