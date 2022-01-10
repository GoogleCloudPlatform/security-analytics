SELECT
  protopayload_auditlog.authenticationInfo.principalEmail,
  COUNT(*) AS COUNTER
FROM `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_data_access`,
  UNNEST(protopayload_auditlog.authorizationInfo) authorizationInfo
WHERE
  (protopayload_auditlog.methodName = "google.cloud.bigquery.v2.JobService.InsertJob" OR
   protopayload_auditlog.methodName = "google.cloud.bigquery.v2.JobService.Query")
  AND authorizationInfo.permission = "bigquery.tables.getData"
  AND authorizationInfo.resource = "projects/[PROJECT_ID]/datasets/[DATASET_ID]/tables/accounts"
  AND timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY
  1
ORDER BY
  2 desc, 1
LIMIT
  100