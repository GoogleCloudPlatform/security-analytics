SELECT
  COALESCE(
   JSON_EXTRACT_SCALAR(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.queryConfig.query"),
   JSON_EXTRACT_SCALAR(protopayload_auditlog.metadataJson, "$.jobInsertion.job.jobConfig.queryConfig.query")) as query,
  STRING_AGG(DISTINCT protopayload_auditlog.authenticationInfo.principalEmail, ',') as users,
  ANY_VALUE(COALESCE(
   JSON_EXTRACT_ARRAY(protopayload_auditlog.metadataJson, "$.jobChange.job.jobStats.queryStats.referencedTables"),
   JSON_EXTRACT_ARRAY(protopayload_auditlog.metadataJson, "$.jobInsertion.job.jobStats.queryStats.referencedTables"))) as tables,
  COUNT(*) AS counter
FROM `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_data_access`
WHERE
  (resource.type = 'bigquery_project' OR resource.type = 'bigquery_dataset')
  AND operation.last IS TRUE
  AND (JSON_EXTRACT(protopayload_auditlog.metadataJson, "$.jobChange") IS NOT NULL
    OR JSON_EXTRACT(protopayload_auditlog.metadataJson, "$.jobInsertion") IS NOT NULL)
  AND timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
GROUP BY
  query
ORDER BY
  counter DESC
LIMIT 10