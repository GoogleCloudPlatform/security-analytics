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
  receive_timestamp, timestamp AS eventTimestamp,
  proto_payload.audit_log.request_metadata.caller_ip,
  proto_payload.audit_log.authentication_info.principal_email, 
  proto_payload.audit_log.resource_name,
  proto_payload.audit_log.method_name
FROM 
  `[MY_PROJECT_ID].[MY_DATASET_ID]._AllLogs`
WHERE
  proto_payload.audit_log.method_name = "v1.compute.subnetworks.patch" 
AND JSON_VALUE(proto_payload.audit_log.request, "$.logConfig.enable") = "false"
