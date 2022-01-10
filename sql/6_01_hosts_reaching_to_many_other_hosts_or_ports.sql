SELECT
  TIMESTAMP_TRUNC(TIMESTAMP(REGEXP_REPLACE(jsonPayload.start_time, r'\.(\d{0,6})\d+(Z)?$', '.\\1\\2')), HOUR) as time_window,
  jsonPayload.connection.src_ip as src_ip,
  COUNT(DISTINCT jsonPayload.connection.dest_ip) as numDestIps,
  COUNT(DISTINCT jsonPayload.connection.dest_port) as numDestPorts,
  ARRAY_AGG(DISTINCT resource.labels.subnetwork_name) as subnetNames,
  ARRAY_AGG(DISTINCT IF(jsonPayload.reporter = 'DEST', jsonPayload.dest_instance.vmNames, jsonPayload.src_instance.vm_name)) as VMs,
  COUNT(*) numSamples
FROM `[MY_PROJECT_ID].[MY_DATASET_ID].compute_googleapis_com_vpc_flows`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY
  time_window,
  src_ip
HAVING numDestIps > 10 OR numDestPorts > 10
ORDER BY
  time_window DESC