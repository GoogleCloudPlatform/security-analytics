SELECT
  timestamp,
  protopayload_auditlog.authenticationInfo.principalEmail as principalEmail,
  protopayload_auditlog.requestMetadata.callerIp,
  protopayload_auditlog.methodName,
  protopayload_auditlog.resourceName,
  JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.queryConfig.query") AS query
FROM
  `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_*`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
  AND resource.type LIKE "bigquery%"
  AND (
    (JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.type") = 'QUERY'
      AND JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.queryConfig.statementType") IN (
        "UPDATE", "DELETE", "DROP_TABLE", "ALTER_TABLE", "TRUNCATE_TABLE"
    )) OR
    (JSON_EXTRACT(protopayload_auditlog.metadataJson, "$.tableDeletion") IS NOT NULL) OR
    (JSON_EXTRACT(protopayload_auditlog.metadataJson, "$.datasetDeletion") IS NOT NULL)
  )
ORDER BY
  timestamp DESC