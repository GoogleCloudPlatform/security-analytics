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
  proto_payload.audit_log.resource_name,
  proto_payload.audit_log.authentication_info.principal_email,
  COUNTIF(JSON_VALUE(proto_payload.audit_log.metadata, "$.tableDataRead") IS NOT NULL) AS dataReadEvents,
  COUNTIF(JSON_VALUE(proto_payload.audit_log.metadata, "$.tableDataChange") IS NOT NULL) AS dataChangeEvents,
  COUNT(*) AS totalEvents
FROM 
  `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`
WHERE
  STARTS_WITH(resource.type, 'bigquery') IS TRUE
  AND (JSON_VALUE(proto_payload.audit_log.metadata, "$.tableDataRead") IS NOT NULL
    OR JSON_VALUE(proto_payload.audit_log.metadata, "$.tableDataChange") IS NOT NULL)
  AND timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY
  1, 2
ORDER BY
  5 DESC, 1, 2
LIMIT 1000
