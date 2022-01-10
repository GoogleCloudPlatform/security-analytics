SELECT
  ANY_VALUE(_TABLE_SUFFIX),
  protopayload_auditlog.methodName,
  protopayload_auditlog.serviceName,
  resource.type,
  COUNT(*) AS counter
FROM `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_data_access`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY
  protopayload_auditlog.methodName,
  protopayload_auditlog.serviceName,
  resource.type
ORDER BY
  counter DESC
LIMIT 100