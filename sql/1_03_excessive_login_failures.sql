SELECT
  protopayload_auditlog.authenticationInfo.principalEmail,
  MIN(timestamp) AS earliest,
  MAX(timestamp) AS latest,
  count(*) AS attempts
FROM
 `[MY_DATASET_ID].[MY_PROJECT_ID].cloudaudit_googleapis_com_data_access`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)
  AND protopayload_auditlog.serviceName="login.googleapis.com"
  AND protopayload_auditlog.methodName="google.login.LoginService.LoginFailure"
GROUP BY
  1
HAVING
  attempts >= 3