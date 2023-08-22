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
  COALESCE(
   JSON_VALUE(proto_payload.audit_log.metadata, "$.jobChange.job.jobConfig.queryConfig.query"),
   JSON_VALUE(proto_payload.audit_log.metadata, "$.jobInsertion.job.jobConfig.queryConfig.query")) as query,
  STRING_AGG(DISTINCT proto_payload.audit_log.authentication_info.principal_email, ',') as users,
  ANY_VALUE(COALESCE(
   JSON_EXTRACT_ARRAY(proto_payload.audit_log.metadata, "$.jobChange.job.jobStats.queryStats.referencedTables"),
   JSON_EXTRACT_ARRAY(proto_payload.audit_log.metadata, "$.jobInsertion.job.jobStats.queryStats.referencedTables"))) as tables,
  COUNT(*) AS counter
FROM 
  `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`
WHERE
  (resource.type = 'bigquery_project' OR resource.type = 'bigquery_dataset')
  AND operation.last IS TRUE
  AND (JSON_VALUE(proto_payload.audit_log.metadata, "$.jobChange") IS NOT NULL
    OR JSON_VALUE(proto_payload.audit_log.metadata, "$.jobInsertion") IS NOT NULL)
  AND timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
GROUP BY
  query
ORDER BY
  counter DESC
LIMIT 10
