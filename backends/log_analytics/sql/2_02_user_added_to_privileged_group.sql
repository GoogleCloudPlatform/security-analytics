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
  proto_payload.audit_log.method_name,
  proto_payload.audit_log.resource_name,
  (SELECT JSON_VALUE(x.value)
   FROM UNNEST(JSON_QUERY_ARRAY(proto_payload.audit_log.metadata.event[0].parameter)) AS x
   WHERE JSON_VALUE(x.name) = "USER_EMAIL") AS user_email,
  (SELECT JSON_VALUE(x.value)
   FROM UNNEST(JSON_QUERY_ARRAY(proto_payload.audit_log.metadata.event[0].parameter)) AS x
   WHERE JSON_VALUE(x.name) = "GROUP_EMAIL") AS group_email,
FROM `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 120 DAY)
  AND proto_payload.audit_log.service_name = "admin.googleapis.com"
  AND proto_payload.audit_log.method_name = "google.admin.AdminService.addGroupMember"
  AND EXISTS(
    SELECT * FROM UNNEST(JSON_QUERY_ARRAY(proto_payload.audit_log.metadata.event[0].parameter)) AS x
    WHERE
      JSON_VALUE(x.name) = "GROUP_EMAIL"
      AND REGEXP_CONTAINS(JSON_VALUE(x.value), r'(admin|prod).*') -- Update regexp with other sensitive groups if applicable
  )