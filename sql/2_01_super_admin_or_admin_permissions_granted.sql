SELECT
 *
FROM
 `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_activity`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 180 DAY)
  (protopayload_auditlog.methodName LIKE "%AdminService.assignRole%"
    OR protopayload_auditlog.methodName LIKE "%AdminService.addPrivilege%")