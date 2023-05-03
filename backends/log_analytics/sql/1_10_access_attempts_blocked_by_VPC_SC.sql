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
  log_name,
  proto_payload.audit_log.authentication_info.principal_email,
  proto_payload.audit_log.request_metadata.caller_ip,
  proto_payload.audit_log.method_name,
  proto_payload.audit_log.service_name,
  JSON_VALUE(proto_payload.audit_log.metadata.violationReason) as violationReason, 
  IF(JSON_VALUE(proto_payload.audit_log.metadata.ingressViolations) IS NULL, 'ingress', 'egress') AS violationType,
  COALESCE(
    JSON_VALUE(proto_payload.audit_log.metadata.ingressViolations[0].targetResource),
    JSON_VALUE(proto_payload.audit_log.metadata.egressViolations[0].targetResource)
  ) AS  targetResource,
  COALESCE(
    JSON_VALUE(proto_payload.audit_log.metadata.ingressViolations[0].servicePerimeter),
    JSON_VALUE(proto_payload.audit_log.metadata.egressViolations[0].servicePerimeter)
  ) AS  servicePerimeter
FROM `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
  AND proto_payload.audit_log IS NOT NULL
  AND JSON_VALUE(proto_payload.audit_log.metadata, '$."@type"') = 'type.googleapis.com/google.cloud.audit.VpcServiceControlAuditMetadata'
ORDER BY
  timestamp DESC
LIMIT 1000
