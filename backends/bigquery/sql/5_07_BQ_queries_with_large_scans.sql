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
  protopayload_auditlog.authenticationInfo.principalEmail as principalEmail,
  protopayload_auditlog.requestMetadata.callerIp,
  CAST(JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobStats.queryStats.totalBilledBytes") AS INT64) AS totalBilledBytes,
  JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.queryConfig.query") AS query
FROM
  `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_data_access`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
  AND operation.last = TRUE 
  AND STARTS_WITH(resource.type, 'bigquery') IS TRUE
  AND JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.type") = "QUERY"
  AND JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.queryConfig.statementType") = "SELECT"
  AND CAST(JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobStats.queryStats.totalBilledBytes") AS INT64) > 1073741824
ORDER BY
  timestamp DESC