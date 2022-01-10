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