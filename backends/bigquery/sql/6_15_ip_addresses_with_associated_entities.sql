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

WITH all_ips AS
  (SELECT *,
    jsonPayload.reporter AS reporter,
    IF(jsonPayload.reporter = 'SRC', jsonPayload.connection.src_ip, jsonPayload.connection.dest_ip) AS reporter_ip,
    IF(jsonPayload.reporter = 'SRC', jsonPayload.connection.dest_ip, jsonPayload.connection.src_ip) AS other_ip,
    IF(jsonPayload.reporter = 'SRC', jsonPayload.src_instance.vm_name, jsonPayload.dest_instance.vm_name) AS reporter_vm_name,
    IF(jsonPayload.reporter = 'SRC', jsonPayload.src_vpc.vpc_name, jsonPayload.dest_vpc.vpc_name) AS reporter_vpc_name,
    IF(jsonPayload.reporter = 'SRC', jsonPayload.dest_location.asn, jsonPayload.src_location.asn) AS external_net_asn,
    IF(jsonPayload.reporter = 'SRC', jsonPayload.dest_location.country, jsonPayload.src_location.country) AS external_net_county,
    [jsonPayload.connection.src_ip, jsonPayload.connection.dest_ip] AS src_dest_ip_pair
  FROM `[MY_PROJECT_ID].[MY_DATASET_ID].compute_googleapis_com_vpc_flows`
  WHERE
    timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY))
SELECT
  ip,
  LOGICAL_OR((offset = 0 AND reporter = 'SRC') OR (offset = 1 AND reporter = 'DEST')) AS internal_entity,
  -- TIMESTAMP supports up to 6 digits of fractional precision, so drop any more digits to avoid parse errors
  MIN(TIMESTAMP(REGEXP_REPLACE(jsonPayload.start_time, r'\.(\d{0,6})\d+(Z)?$', '.\\1\\2'))) AS ip_first_seen,
  MAX(TIMESTAMP(REGEXP_REPLACE(jsonPayload.start_time, r'\.(\d{0,6})\d+(Z)?$', '.\\1\\2'))) AS ip_last_seen,
  FORMAT('%.2f', SUM(IF(offset = 0, CAST(jsonPayload.bytes_sent AS INT64)/POWER(2, 30), 0))) AS outbound_traffic_gb,
  FORMAT('%.2f', SUM(IF(offset = 1, CAST(jsonPayload.bytes_sent AS INT64)/POWER(2, 30), 0))) AS inbound_traffic_gb,
  ARRAY_AGG(DISTINCT
    IF((offset = 0 AND reporter = 'SRC') OR (offset = 1 AND reporter = 'DEST'), reporter_vm_name, NULL) IGNORE NULLS) AS vm_names,
  ARRAY_AGG(DISTINCT
    IF((offset = 0 AND reporter = 'SRC') OR (offset = 1 AND reporter = 'DEST'), reporter_vpc_name, NULL) IGNORE NULLS) AS vpc_names,
  ANY_VALUE(
    IF((offset = 1 AND reporter = 'SRC') OR (offset = 0 AND reporter = 'DEST'), external_net_asn, NULL)) AS external_net_asn,
  ANY_VALUE(
    IF((offset = 1 AND reporter = 'SRC') OR (offset = 0 AND reporter = 'DEST'), external_net_county, NULL)) AS external_net_county,
  ARRAY_AGG(DISTINCT
    IF((offset = 0 AND reporter = 'SRC') OR (offset = 1 AND reporter = 'DEST'), other_ip, reporter_ip) IGNORE NULLS) as connected_ips,
  COUNT(*) AS flow_count,
FROM all_ips, all_ips.src_dest_ip_pair AS ip WITH OFFSET AS offset
GROUP BY ip
ORDER BY internal_entity DESC, flow_count DESC