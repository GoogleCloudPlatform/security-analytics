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
  tr.jsonPayload.session_id,
  MIN(TIMESTAMP(tr.jsonPayload.start_time)) as start_time,
  SUM(CAST(tr.jsonPayload.elapsed_time AS INT64)) as elapsed_time,
  ARRAY_AGG(DISTINCT tr.jsonPayload.application IGNORE NULLS) as application,
  ANY_VALUE(tr.jsonPayload.ip_protocol) as ip_protocol,
  ANY_VALUE(tr.jsonPayload.source_ip_address) as source_ip_address,
  ARRAY_AGG(DISTINCT tr.jsonPayload.source_port IGNORE NULLS) as source_ports,
  ANY_VALUE(tr.jsonPayload.destination_ip_address) as destination_ip_address,
  ARRAY_AGG(DISTINCT tr.jsonPayload.destination_port IGNORE NULLS) as destination_ports,
  SUM(CAST(tr.jsonPayload.total_bytes AS INT64)) as total_bytes,
  SUM(CAST(tr.jsonPayload.total_packets AS INT64)) as total_packets,
  ANY_VALUE(tr.jsonPayload.network) as network
FROM
 `[MY_PROJECT_ID].[MY_DATASET_ID].ids_googleapis_com_traffic` AS tr
RIGHT OUTER JOIN `[MY_PROJECT_ID].[MY_DATASET_ID].ids_googleapis_com_traffic` AS th
ON tr.jsonPayload.session_id = th.jsonPayload.session_id
WHERE
  tr.timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
  AND th.timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
  AND th.jsonPayload.alert_severity IN ("HIGH", "CRITICAL")
GROUP BY
  tr.jsonPayload.session_id