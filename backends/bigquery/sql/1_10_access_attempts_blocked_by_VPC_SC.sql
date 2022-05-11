/*
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
 `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_policy`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 400 DAY)
  AND JSON_VALUE(protopayload_auditlog.metadataJson, '$."@type"') = 'type.googleapis.com/google.cloud.audit.VpcServiceControlAuditMetadata'
ORDER BY
  timestamp DESC
LIMIT 1000