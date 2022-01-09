SELECT
  timestamp,
  protopayload_auditlog.authenticationInfo.principalEmail,
  protopayload_auditlog.requestMetadata.callerIp,
  protopayload_auditlog.methodName,
  protopayload_auditlog.serviceName,
  JSON_VALUE(protopayload_auditlog.metadataJson, '$.violationReason') as violationReason, 
  IF(JSON_VALUE(protopayload_auditlog.metadataJson, '$.ingressViolations') IS NULL, 'ingress', 'egress') AS violationType,
  COALESCE(
    JSON_VALUE(protopayload_auditlog.metadataJson, '$.ingressViolations[0].targetResource'),
    JSON_VALUE(protopayload_auditlog.metadataJson, '$.egressViolations[0].targetResource')
  ) AS  targetResource,
  COALESCE(
    JSON_VALUE(protopayload_auditlog.metadataJson, '$.ingressViolations[0].servicePerimeter'),
    JSON_VALUE(protopayload_auditlog.metadataJson, '$.egressViolations[0].servicePerimeter')
  ) AS  servicePerimeter
FROM
 `[MY_DATASET_ID].[MY_PROJECT_ID].cloudaudit_googleapis_com_policy`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 400 DAY)
  AND JSON_VALUE(protopayload_auditlog.metadataJson, '$."@type"') = 'type.googleapis.com/google.cloud.audit.VpcServiceControlAuditMetadata'
ORDER BY
  timestamp DESC
LIMIT 1000