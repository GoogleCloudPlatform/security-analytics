/*
 * Copyright 2024 Google LLC
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

/*
 * ||||||||||||||||||||||||||||||||||||||
 *   Log Analytics chart configuration:
 * ||||||||||||||||||||||||||||||||||||||
 * - Chart type: Bar chart - Horizontal
 * - Dimension (y-axis): principal_email
 * - Measure (x-axis): counter
 * - Breakdown: model_name 
 */

SELECT
  proto_payload.audit_log.authentication_info.principal_email,
  SUBSTR(proto_payload.audit_log.resource_name, (STRPOS(proto_payload.audit_log.resource_name, 'publishers/') + 11)) as model_name,
  COUNT(*) as counter
FROM
  `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`
WHERE
  -- timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY) AND
  proto_payload.audit_log.service_name = "aiplatform.googleapis.com" AND
  SPLIT(proto_payload.audit_log.method_name, '.')[SAFE_OFFSET(5)] IN ("Predict", "GenerateContent")
GROUP BY
  1, 2
ORDER BY
  counter DESC
LIMIT 1000
