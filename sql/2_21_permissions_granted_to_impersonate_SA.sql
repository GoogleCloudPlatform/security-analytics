SELECT
 timestamp,
 logName,
 protopayload_auditlog.authenticationInfo.principalEmail,
 protopayload_auditlog.methodName,
 protopayload_auditlog.resourceName,
 bindingDelta
FROM
 `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_activity`,
  UNNEST(protopayload_auditlog.servicedata_v1_iam.policyDelta.bindingDeltas) AS bindingDelta
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 180 DAY)
  AND resource.type="service_account"
  AND protopayload_auditlog.methodName LIKE "google.iam.admin.%.SetIAMPolicy"
  AND bindingDelta.action = 'ADD'
  AND bindingDelta.role IN (
    'roles/iam.serviceAccountTokenCreator',
    'roles/iam.serviceAccountUser'
  )
