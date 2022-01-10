SELECT
  timestamp,
  protopayload_auditlog.authenticationInfo.principalEmail as principalEmail,
  protopayload_auditlog.requestMetadata.callerIp,
  JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.type") as jobType,
  IF (JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.type") = 'EXPORT',
    JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.extractConfig.sourceTable"),
    ARRAY_TO_STRING(JSON_VALUE_ARRAY(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.tableCopyConfig.sourceTables"), ',')) as source,
  IF (JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.type") = 'EXPORT',
    ARRAY_TO_STRING(JSON_VALUE_ARRAY(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.extractConfig.destinationUris"), ','),
    JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.tableCopyConfig.destinationTable")) as destination,
  CAST(JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobStats.extractStats.totalInputBytes") AS INT64) AS totalBytes,
FROM
  `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_data_access`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
  AND operation.last = TRUE
  AND STARTS_WITH(resource.type, 'bigquery') IS TRUE
  AND JSON_VALUE(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.type") IN ("COPY", "EXPORT")
ORDER BY
  timestamp DESC