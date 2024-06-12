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
  proto_payload.audit_log.authentication_info.principal_email,
  COUNT(*) AS COUNTER
FROM 
   `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`
WHERE
  (proto_payload.audit_log.method_name = "google.cloud.bigquery.v2.JobService.InsertJob" OR
   proto_payload.audit_log.method_name = "google.cloud.bigquery.v2.JobService.Query")
  AND log_id = "cloudaudit.googleapis.com/data_access"
GROUP BY
  1
ORDER BY
  2 desc, 1
LIMIT
  100
