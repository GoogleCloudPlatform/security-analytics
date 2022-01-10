SELECT
  timestamp,
  protopayload_auditlog.authenticationInfo.principalEmail as principalEmail,
  protopayload_auditlog.requestMetadata.callerIp,
  CAST(JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobStats.queryStats.totalBilledBytes") AS INT64) AS totalBilledBytes,
  JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.queryConfig.query") AS query
FROM
  `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_data_access`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
  AND operation.last = TRUE 
  AND STARTS_WITH(resource.type, 'bigquery') IS TRUE
  AND JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.type") = "QUERY"
  AND JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.queryConfig.statementType") = "SELECT"
  AND CAST(JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobStats.queryStats.totalBilledBytes") AS INT64) > 1073741824
ORDER BY
  timestamp DESC