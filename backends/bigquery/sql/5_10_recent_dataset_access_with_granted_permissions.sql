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
  protopayload_auditlog.authenticationInfo.principalEmail as user_email,
  protopayload_auditlog.requestMetadata.callerIp as ip,
  auth.permission as auth_permission,
  auth.granted as auth_granted,
  data_access.resource.labels.project_id AS job_execution_project,
  SPLIT(protopayload_auditlog.resourceName, '/')[SAFE_OFFSET(1)] AS referenced_project,
  SPLIT(protopayload_auditlog.resourceName, '/')[SAFE_OFFSET(3)] AS referenced_dataset,
  SPLIT(protopayload_auditlog.resourceName, '/')[SAFE_OFFSET(5)] AS referenced_table,
  ARRAY_LENGTH(SPLIT(JSON_EXTRACT(JSON_EXTRACT(protopayload_auditlog.metadataJson, '$.tableDataRead'), '$.fields'), ','))  as num_fields,
  SPLIT(JSON_EXTRACT(JSON_EXTRACT(protopayload_auditlog.metadataJson, '$.tableDataRead'), '$.fields'),",") as fields
FROM `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_data_access` As data_access,
  UNNEST(protopayload_auditlog.authorizationInfo) AS auth
WHERE
  protopayload_auditlog.methodName = "google.cloud.bigquery.v2.JobService.InsertJob"
  AND data_access.resource.type = 'bigquery_dataset'
  AND JSON_EXTRACT(JSON_EXTRACT(protopayload_auditlog.metadataJson, '$.tableDataRead'), '$.reason') = '"JOB"'
  AND timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)