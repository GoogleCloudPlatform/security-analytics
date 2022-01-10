SELECT
  timestamp,
  protopayload_auditlog.authenticationInfo.principalEmail,
  protopayload_auditlog.methodName,
  protopayload_auditlog.resourceName
FROM `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_activity`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)
  AND protopayload_auditlog.methodName IN (
    "v1.compute.firewalls.insert",
    "v1.compute.firewalls.delete",
    "v1.compute.firewalls.patch",
    "v1.compute.firewalls.update"
  )