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
  IF(MIN(timestamp) >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY), 1, 0) AS isNew,
  protopayload_auditlog.authenticationInfo.principalEmail,
  MIN(timestamp) AS firstInstance,
  MAX(timestamp) AS lastInstance,
  ARRAY_AGG(DISTINCT protopayload_auditlog.methodName IGNORE NULLS) as methodNames,
  ARRAY_AGG(DISTINCT COALESCE(protopayload_auditlog.resourceName, 'ALL')) as resourceNames,
  ARRAY_AGG(DISTINCT protopayload_auditlog.requestMetadata.callerSuppliedUserAgent IGNORE NULLS) as userAgents,
  COUNT(*) counter
FROM `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_data_access`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY)
  AND protopayload_auditlog.serviceName = 'storage.googleapis.com'
  AND protopayload_auditlog.methodName LIKE 'storage.%.list'
  AND protopayload_auditlog.authenticationInfo.principalEmail NOT IN (
    -- Actor exclusions
    "service-account-123456@developer.gserviceaccount.com",
    "user@example.com"
  )
  AND (protopayload_auditlog.resourceName NOT IN (
    -- Resource (bucket) exclusions
    "projects/_/buckets/non-sensitive-bucket"
  ) OR protopayload_auditlog.resourceName IS NULL)
GROUP BY
  principalEmail
ORDER BY
  isNew DESC,
  lastInstance DESC,
  counter DESC