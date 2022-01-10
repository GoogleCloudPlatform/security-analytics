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
  resource.type,
  protopayload_auditlog.resourceName,
  JSON_VALUE(binding, '$.role') as role,
  JSON_VALUE_ARRAY(binding, '$.members') as members
FROM
  `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_activity`,
  UNNEST(JSON_QUERY_ARRAY(protopayload_auditlog.responseJson, '$.bindings')) AS binding
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 400 DAY)
  AND protopayload_auditlog.serviceName = "iap.googleapis.com"
  AND protopayload_auditlog.methodName LIKE "%.IdentityAwareProxyAdminService.SetIamPolicy"
  AND JSON_VALUE(binding, '$.role') = "roles/iap.httpsResourceAccessor"
ORDER BY
  timestamp DESC