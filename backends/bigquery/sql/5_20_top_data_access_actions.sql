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
  protopayload_auditlog.methodName,
  protopayload_auditlog.serviceName,
  resource.type,
  COUNT(*) AS counter
FROM `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_data_access`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY
  protopayload_auditlog.methodName,
  protopayload_auditlog.serviceName,
  resource.type
ORDER BY
  counter DESC
LIMIT 100