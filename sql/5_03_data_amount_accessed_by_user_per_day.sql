SELECT
  TIMESTAMP_TRUNC(TIMESTAMP(JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobStats.endTime")), DAY) AS time_window,
  protopayload_auditlog.authenticationInfo.principalEmail as principalEmail,
  FORMAT('%9.3f',SUM(CAST(JSON_VALUE(protopayload_auditlog.metadataJson,
      "$.jobChange.job.jobStats.queryStats.totalBilledBytes") AS INT64))/POWER(2, 40)) AS Billed_TB
FROM
  `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_data_access`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
  AND JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.type") = "QUERY"
GROUP BY
  time_window,
  principalEmail
ORDER BY
  time_window DESC,
  Billed_TB DESC