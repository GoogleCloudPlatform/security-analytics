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
  proto_payload.audit_log.authentication_info.principal_email as actor,
  proto_payload.audit_log.method_name as action,
  proto_payload.audit_log.resource_name as resource,
  COALESCE(service_account_delegation_info.first_party_principal.principal_email,
    STRING(service_account_delegation_info.third_party_principal.third_party_claims)
  ) as impersonated_by
FROM `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`
  LEFT JOIN UNNEST(proto_payload.audit_log.authentication_info.service_account_delegation_info) as service_account_delegation_info
WHERE
  proto_payload.audit_log.authentication_info.principal_email IS NOT NULL
  -- Actor(s) to be investigated
  AND proto_payload.audit_log.authentication_info.principal_email IN (
    "[MY_COMPROMISED_SA]@[MY_PROJECT_ID].iam.gserviceaccount.com"
  )
ORDER BY
  timestamp DESC
