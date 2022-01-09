SELECT
  timestamp,
  protopayload_auditlog.authenticationInfo.principalEmail,
  protopayload_auditlog.methodName,
  protopayload_auditlog.requestMetadata.callerIp,
  JSON_EXTRACT(protopayload_auditlog.metadataJson, "$.event[0].parameter[0].value") AS loginType
FROM `[MY_DATASET_ID].[MY_PROJECT_ID].cloudaudit_googleapis_com_data_access`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY)
  AND protopayload_auditlog.authenticationInfo.principalEmail LIKE "admin%"
  AND protopayload_auditlog.serviceName = "login.googleapis.com"
  AND protopayload_auditlog.methodName LIKE "google.login.LoginService.%"