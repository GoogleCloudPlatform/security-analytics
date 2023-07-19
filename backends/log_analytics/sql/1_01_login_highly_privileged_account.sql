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
  proto_payload.audit_log.request_metadata.caller_ip,
  JSON_VALUE(proto_payload.audit_log.metadata.event[0].parameter[0].value) AS login_type
FROM `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY)
  AND proto_payload.audit_log IS NOT NULL
  AND proto_payload.audit_log.authentication_info.principal_email LIKE "admin%"
  AND proto_payload.audit_log.service_name = "login.googleapis.com"
  AND proto_payload.audit_log.method_name LIKE "google.login.LoginService.%"
