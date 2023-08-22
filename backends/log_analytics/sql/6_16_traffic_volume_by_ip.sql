/*
 * Copyright 2023 Google LLC
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
  reporter_ip,
  ANY_VALUE(vm_names HAVING MAX ARRAY_LENGTH(vm_names)) AS vm_names,
  ANY_VALUE(vpc_names HAVING MAX ARRAY_LENGTH(vpc_names)) AS vpc_names,
  ARRAY_AGG(STRUCT(
    other_ip, flow_count,
    bytes_sent, bytes_received,
    packets_sent, packets_received,
    external_net_asn, external_net_country) ORDER BY flow_count DESC) AS connections
FROM(
  SELECT
    reporter_ip,
    other_ip,
    ARRAY_AGG(DISTINCT reporter_vm_name IGNORE NULLS) AS vm_names,
    ARRAY_AGG(DISTINCT reporter_vpc_name IGNORE NULLS) AS vpc_names,
    ARRAY_AGG(DISTINCT external_net_asn IGNORE NULLS) AS external_net_asn,
    ARRAY_AGG(DISTINCT external_net_country IGNORE NULLS) AS external_net_country,
    SUM(bytes_sent) AS bytes_sent,
    SUM(bytes_received) AS bytes_received,
    SUM(packets_sent) AS packets_sent,
    SUM(packets_received) AS packets_received,
    COUNT(*) AS flow_count,
  FROM (
    SELECT
      JSON_VALUE(json_payload.reporter) AS reporter,
      TIMESTAMP(REGEXP_REPLACE(JSON_VALUE(json_payload.start_time), r'\.(\d{0,6})\d+(Z)?$', '.\\1\\2')) AS start_time,
      TIMESTAMP(REGEXP_REPLACE(JSON_VALUE(json_payload.end_time), r'\.(\d{0,6})\d+(Z)?$', '.\\1\\2')) AS end_time,
      IF(JSON_VALUE(json_payload.reporter) = 'SRC', JSON_VALUE(json_payload.connection.src_ip), JSON_VALUE(json_payload.connection.dest_ip)) AS reporter_ip,
      IF(JSON_VALUE(json_payload.reporter) = 'SRC', JSON_VALUE(json_payload.connection.dest_ip), JSON_VALUE(json_payload.connection.src_ip)) AS other_ip,
      IF(JSON_VALUE(json_payload.reporter) = 'SRC', JSON_VALUE(json_payload.src_instance.vm_name), JSON_VALUE(json_payload.dest_instance.vm_name)) AS reporter_vm_name,
      IF(JSON_VALUE(json_payload.reporter) = 'SRC', JSON_VALUE(json_payload.src_vpc.vpc_name), JSON_VALUE(json_payload.dest_vpc.vpc_name)) AS reporter_vpc_name,
      IF(JSON_VALUE(json_payload.reporter) = 'SRC', JSON_VALUE(json_payload.dest_location.asn), JSON_VALUE(json_payload.src_location.asn)) AS external_net_asn,
      IF(JSON_VALUE(json_payload.reporter) = 'SRC', JSON_VALUE(json_payload.dest_location.country), JSON_VALUE(json_payload.src_location.country)) AS external_net_country,
      IF(JSON_VALUE(json_payload.reporter) = 'SRC', CAST(JSON_VALUE(json_payload.bytes_sent) as INT64), 0) AS bytes_sent,
      IF(JSON_VALUE(json_payload.reporter) = 'SRC', 0, CAST(JSON_VALUE(json_payload.bytes_sent) as INT64)) AS bytes_received,
      IF(JSON_VALUE(json_payload.reporter) = 'SRC', CAST(JSON_VALUE(json_payload.packets_sent) as INT64), 0) AS packets_sent,
      IF(JSON_VALUE(json_payload.reporter) = 'SRC', 0, CAST(JSON_VALUE(json_payload.packets_sent) as INT64)) AS packets_received
    FROM `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`
    WHERE
      timestamp >=  TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
      AND log_id = 'compute.googleapis.com/vpc_flows'
  )
  GROUP BY
    reporter_ip, other_ip
  )
GROUP BY
  reporter_ip
