SELECT
  jsonPayload.connection.src_ip as src_ip,
  MIN(TIMESTAMP(REGEXP_REPLACE(jsonPayload.start_time, r'\.(\d{0,6})\d+(Z)?$', '.\\1\\2'))) AS firstInstance, --- TIMESTAMP supports up to 6 digits of fractional precision, so drop any more digits to avoid parse errors
  MAX(TIMESTAMP(REGEXP_REPLACE(jsonPayload.start_time, r'\.(\d{0,6})\d+(Z)?$', '.\\1\\2'))) AS lastInstance,
  ARRAY_AGG(DISTINCT resource.labels.subnetwork_name) as subnetNames,
  ARRAY_AGG(DISTINCT jsonPayload.dest_instance.vm_name) as vmNames,
  COUNT(*) numSamples
FROM `[MY_PROJECT_ID].[MY_DATASET_ID].compute_googleapis_com_vpc_flows`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY)
  AND jsonPayload.reporter = 'DEST'
  AND resource.labels.subnetwork_name IN ('prod-customer-data')
GROUP BY
  src_ip
HAVING firstInstance >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)
ORDER BY
  lastInstance DESC,
  numSamples DESC
