SELECT
  protopayload_auditlog.authenticationInfo.principalEmail,
  COUNT(*) AS COUNTER
FROM `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_data_access`
WHERE
  (protopayload_auditlog.methodName = "google.cloud.bigquery.v2.JobService.InsertJob" OR
   protopayload_auditlog.methodName = "google.cloud.bigquery.v2.JobService.Query")
  AND timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
GROUP BY
  1
ORDER BY
  2 desc, 1
LIMIT
  100