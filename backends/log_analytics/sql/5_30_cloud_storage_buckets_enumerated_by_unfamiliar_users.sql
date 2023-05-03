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
  IF(MIN(timestamp) >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY), 1, 0) AS is_new,
  proto_payload.audit_log.authentication_info.principal_email,
  MIN(timestamp) AS first_instance,
  MAX(timestamp) AS last_instance,
  ARRAY_AGG(DISTINCT proto_payload.audit_log.method_name IGNORE NULLS) as method_names,
  ARRAY_AGG(DISTINCT COALESCE(proto_payload.audit_log.resource_name, 'ALL')) as resource_names,
  ARRAY_AGG(DISTINCT proto_payload.audit_log.request_metadata.caller_supplied_user_agent IGNORE NULLS) as user_agents,
  COUNT(*) counter
FROM `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY)
  AND proto_payload.audit_log.service_name = 'storage.googleapis.com'
  AND proto_payload.audit_log.method_name LIKE 'storage.%.list'
  AND proto_payload.audit_log.authentication_info.principal_email NOT IN (
    -- Actor exclusions
    "service-account-123456@developer.gserviceaccount.com",
    "user@example.com"
  )
  AND (proto_payload.audit_log.resource_name NOT IN (
    -- Resource (bucket) exclusions
    "projects/_/buckets/non-sensitive-bucket"
  ) OR proto_payload.audit_log.resource_name IS NULL)
GROUP BY
  principal_email
ORDER BY
  is_new DESC,
  last_instance DESC,
  counter DESC
