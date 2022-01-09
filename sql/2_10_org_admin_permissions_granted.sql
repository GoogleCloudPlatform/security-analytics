SELECT
 *
FROM
 `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_activity`,
  UNNEST(protopayload_auditlog.servicedata_v1_iam.policyDelta.bindingDeltas) AS Deltas
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 180 DAY)
  AND protopayload_auditlog.methodName LIKE "%SetIamPolicy%"
  AND Deltas.role LIKE "%roles/resourcemanager.organizationAdmin%"