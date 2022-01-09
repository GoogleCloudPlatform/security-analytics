SELECT
 *
FROM
 `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_activity`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 180 DAY)
  AND resource.type="service_account"
  AND protopayload_auditlog.methodName LIKE "%CreateServiceAccount%"
  AND protopayload_auditlog.authenticationInfo.principalEmail NOT LIKE "%.gserviceaccount.com"
