SELECT
  receiveTimestamp, timestamp AS eventTimestamp,
  protopayload_auditlog.requestMetadata.callerIp,
  protopayload_auditlog.authenticationInfo.principalEmail, 
  protopayload_auditlog.resourceName,
  protopayload_auditlog.methodName
FROM `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_activity`
WHERE
  protopayload_auditlog.serviceName = "logging.googleapis.com"