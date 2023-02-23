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

WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 180 DAY)
  AND resource.type="service_account"
  AND protopayload_auditlog.methodName LIKE "google.iam.admin.%.SetIAMPolicy"
  AND bindingDelta.action = 'ADD'
  AND bindingDelta.role IN (
    'roles/iam.serviceAccountKeyAdmin'
  )

SELECT
  timestamp,
  protopayload_auditlog.authenticationInfo.principalEmail as grantor,
  bindingDelta.member as grantee,
  bindingDelta.role,
  protopayload_auditlog.resourceName,
  protopayload_auditlog.methodName,
FROM
  `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_activity`,
  UNNEST(protopayload_auditlog.servicedata_v1_iam.policyDelta.bindingDeltas) AS bindingDelta
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 180 DAY)
  AND (
    (resource.type = "service_account"
    AND protopayload_auditlog.methodName LIKE "google.iam.admin.%.SetIAMPolicy")
    OR
    (resource.type IN ("project", "folder", "organization")
    AND protopayload_auditlog.methodName = "SetIamPolicy")
  )
  AND bindingDelta.role = 'roles/iam.serviceAccountKeyAdmin'
  AND bindingDelta.action = 'ADD'
  -- Principal (grantee) exclusions
  AND bindingDelta.member NOT LIKE "%@example.com"
ORDER BY
  timestamp DESC