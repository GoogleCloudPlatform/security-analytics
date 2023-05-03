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
  JSON_VALUE(json_payload.connection.src_ip) as src_ip,
  -- TIMESTAMP supports up to 6 digits of fractional precision, so drop any more digits to avoid parse errors
  MIN(TIMESTAMP(REGEXP_REPLACE(JSON_VALUE(json_payload.start_time), r'\.(\d{0,6})\d+(Z)?$', '.\\1\\2'))) AS firstInstance,
  MAX(TIMESTAMP(REGEXP_REPLACE(JSON_VALUE(json_payload.start_time), r'\.(\d{0,6})\d+(Z)?$', '.\\1\\2'))) AS lastInstance,
  ARRAY_AGG(DISTINCT JSON_VALUE(resource.labels.subnetwork_name)) as subnetNames,
  ARRAY_AGG(DISTINCT JSON_VALUE(json_payload.dest_instance.vm_name)) as vmNames,
  COUNT(*) numSamples
FROM `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY)
  AND JSON_VALUE(json_payload.reporter) = 'DEST'
  AND JSON_VALUE(resource.labels.subnetwork_name) IN ('prod-customer-data')
GROUP BY
  src_ip
HAVING firstInstance >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)
ORDER BY
  lastInstance DESC,
  numSamples DESC
