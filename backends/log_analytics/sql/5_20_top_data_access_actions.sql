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
  proto_payload.audit_log.method_name,
  proto_payload.audit_log.service_name,
  resource.type,
  COUNT(*) AS counter
FROM `[MY_PROJECT_ID].[MY_DATASET_ID]._AllLogs`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
  AND log_id="cloudaudit.googleapis.com/data_access"
GROUP BY
  proto_payload.audit_log.method_name,
  proto_payload.audit_log.service_name,
  resource.type,
ORDER BY
  counter DESC
LIMIT 100