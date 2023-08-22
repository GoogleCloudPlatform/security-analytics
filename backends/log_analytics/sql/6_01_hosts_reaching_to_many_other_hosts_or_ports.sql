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
  TIMESTAMP_TRUNC(TIMESTAMP(REGEXP_REPLACE(JSON_VALUE(json_payload.start_time), r'\.(\d{0,6})\d+(Z)?$', '.\\1\\2')), HOUR) as time_window,
  JSON_VALUE(json_payload.connection.src_ip) AS src_ip,
  COUNT(DISTINCT JSON_VALUE(json_payload.connection.dest_ip)) AS numDestIps,
  COUNT(DISTINCT JSON_VALUE(json_payload.connection.dest_port)) AS numDestPorts,
  ARRAY_AGG(DISTINCT JSON_VALUE(resource.labels.subnetwork_name)) AS subnetNames,
  ARRAY_AGG(DISTINCT IF(JSON_VALUE(json_payload.reporter) = "DEST", JSON_VALUE(json_payload.dest_instance.vm_name), JSON_VALUE(json_payload.src_instance.vm_name))) as VMs,
  COUNT(*) numSamples
FROM
  `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
  AND log_id = "compute.googleapis.com/vpc_flows"
GROUP BY
  time_window,
  src_ip
HAVING
  numDestIps > 10
  OR numDestPorts > 10
ORDER BY
   time_window DESC
   