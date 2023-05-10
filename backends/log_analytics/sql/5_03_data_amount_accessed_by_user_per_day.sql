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
  TIMESTAMP_TRUNC(TIMESTAMP(JSON_VALUE(proto_payload.audit_log.metadata, "$.jobChange.job.jobStats.endTime")), DAY) AS time_window,
  proto_payload.audit_log.authentication_info.principal_email as principal_email,
  FORMAT('%9.3f',SUM(CAST(JSON_VALUE(proto_payload.audit_log.metadata,
      "$.jobChange.job.jobStats.queryStats.totalBilledBytes") AS INT64))/POWER(2, 40)) AS Billed_TB
FROM
  `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
  AND JSON_VALUE(proto_payload.audit_log.metadata, "$.jobChange.job.jobConfig.type") = "QUERY"
  AND log_id = "cloudaudit.googleapis.com/data_access"
GROUP BY
  time_window,
  principal_email
ORDER BY
  time_window DESC,
  Billed_TB DESC
