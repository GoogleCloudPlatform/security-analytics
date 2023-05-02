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
  proto_payload.audit_log.authentication_info.principal_email as user_email,
  proto_payload.audit_log.request_metadata.caller_ip as ip,
  auth.permission as auth_permission,
  auth.granted as auth_granted,
  JSON_VALUE(data_access.resource.labels.project_id) AS job_execution_project,
  SPLIT(proto_payload.audit_log.resource_name, '/')[SAFE_OFFSET(1)] AS referenced_project,
  SPLIT(proto_payload.audit_log.resource_name, '/')[SAFE_OFFSET(3)] AS referenced_dataset,
  SPLIT(proto_payload.audit_log.resource_name, '/')[SAFE_OFFSET(5)] AS referenced_table,
  JSON_VALUE_ARRAY(proto_payload.audit_log.metadata.tableDataRead.fields) as fields,
  ARRAY_LENGTH(JSON_VALUE_ARRAY(proto_payload.audit_log.metadata.tableDataRead.fields))  as num_fields,
FROM `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs` As data_access,
  UNNEST(proto_payload.audit_log.authorization_info) AS auth
WHERE
  log_id="cloudaudit.googleapis.com/data_access"
  AND proto_payload.audit_log.method_name = "google.cloud.bigquery.v2.JobService.InsertJob"
  AND data_access.resource.type = 'bigquery_dataset'
  AND JSON_VALUE(proto_payload.audit_log.metadata.tableDataRead.reason) = "JOB"
  AND timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
