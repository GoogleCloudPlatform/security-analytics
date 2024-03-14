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

SELECT
  TIMESTAMP_TRUNC(timestamp, DAY) AS day,
  protopayload_auditlog.resourceName,
  COUNT(*) as counter
FROM
  `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_data_access`
WHERE
  -- in the past week
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY) AND
  protopayload_auditlog.serviceName = "aiplatform.googleapis.com" AND
  SPLIT(protopayload_auditlog.methodName, '.')[SAFE_OFFSET(5)] IN ("Predict", "GenerateContent")
GROUP BY
  1, 2
ORDER BY
  1 DESC, 3 DESC
LIMIT 10000

