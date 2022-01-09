WITH logins AS
(
SELECT
  timestamp,
  protopayload_auditlog.authenticationInfo.principalEmail,
  protopayload_auditlog.requestMetadata.callerIp,
  protopayload_auditlog.resourceName,
  JSON_QUERY_ARRAY(protopayload_auditlog.metadataJson, '$.event[0].parameter') AS parameters,
FROM `[MY_DATASET_ID].[MY_PROJECT_ID].cloudaudit_googleapis_com_data_access`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY)
  AND protopayload_auditlog.serviceName = "login.googleapis.com"
  AND protopayload_auditlog.methodName LIKE "google.login.LoginService.loginSuccess"
)

SELECT
  timestamp, principalEmail, callerIp, resourceName
FROM logins
WHERE EXISTS(
  SELECT * FROM UNNEST(parameters) AS x
  WHERE
    JSON_VALUE(x, '$.name') = 'is_suspicious' AND JSON_VALUE(x, '$.boolValue') = 'false'
)