SELECT
  IF(MIN(timestamp) >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY), 1, 0) AS isNew,
  COALESCE(protopayload_auditlog.requestMetadata.callerIp, 'unknown') as callerIp,
  MIN(timestamp) AS firstInstance,
  MAX(timestamp) AS lastInstance,
  ARRAY_AGG(DISTINCT protopayload_auditlog.authenticationInfo.principalEmail IGNORE NULLS) as principalEmails,
  ARRAY_AGG(DISTINCT protopayload_auditlog.methodName IGNORE NULLS) as methodNames,
  ARRAY_AGG(DISTINCT protopayload_auditlog.resourceName IGNORE NULLS) as resourceNames,
  ARRAY_AGG(DISTINCT protopayload_auditlog.requestMetadata.callerSuppliedUserAgent IGNORE NULLS) as userAgents,
  COUNT(*) counter
FROM `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_data_access`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY)
  AND protopayload_auditlog.serviceName = 'storage.googleapis.com'
  AND protopayload_auditlog.requestMetadata.callerIp IS NOT NULL
  AND protopayload_auditlog.authenticationInfo.principalEmail NOT IN (
    -- Exclusions
    "service-account-123456@developer.gserviceaccount.com",
    "user@example.com"
  )
GROUP BY
  callerIp
ORDER BY
  isNew DESC,
  lastInstance DESC,
  counter DESC