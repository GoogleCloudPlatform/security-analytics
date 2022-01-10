SELECT
  TIMESTAMP_TRUNC(timestamp, DAY) AS day,
  protopayload_auditlog.methodName AS methodName,
  COUNT(*) AS counter
FROM `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_activity`
WHERE
  resource.type = "gce_instance_group_manager"
  AND timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY
  1, 2
ORDER BY
  1, 2