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
  REGEXP_EXTRACT(proto_payload.audit_log.resource_name, 'projects/([^/]+)') as projectid,
  REGEXP_EXTRACT(proto_payload.audit_log.resource_name, '/datasets/([^/]+)') AS datasetid,
  proto_payload.audit_log.authentication_info.principal_email as principalemail,
  proto_payload.audit_log.request_metadata.caller_ip as callerip,
  auth.permission as permission,
  proto_payload.audit_log.request_metadata.caller_supplied_user_agent as agent,
  proto_payload.audit_log.method_name as method,
  proto_payload.audit_log.status.message as status,
  auth.granted as granted
FROM `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`,
  UNNEST(proto_payload.audit_log.authorization_info) as auth
WHERE
  log_id="cloudaudit.googleapis.com/activity"
  AND LOWER(proto_payload.audit_log.method_name) like '%dataset%'
  AND timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
