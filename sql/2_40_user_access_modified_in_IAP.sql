SELECT
  timestamp,
  protopayload_auditlog.authenticationInfo.principalEmail,
  resource.type,
  protopayload_auditlog.resourceName,
  JSON_VALUE(binding, '$.role') as role,
  JSON_VALUE_ARRAY(binding, '$.members') as members
FROM
  `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_activity`,
  UNNEST(JSON_QUERY_ARRAY(protopayload_auditlog.responseJson, '$.bindings')) AS binding
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 400 DAY)
  AND protopayload_auditlog.serviceName = "iap.googleapis.com"
  AND protopayload_auditlog.methodName LIKE "%.IdentityAwareProxyAdminService.SetIamPolicy"
  AND JSON_VALUE(binding, '$.role') = "roles/iap.httpsResourceAccessor"
ORDER BY
  timestamp DESC