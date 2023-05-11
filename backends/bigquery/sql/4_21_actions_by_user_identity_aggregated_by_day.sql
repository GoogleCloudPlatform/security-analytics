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

WITH actions AS (
  SELECT
    timestamp,
    EXTRACT(DATE FROM timestamp) AS day,
    protopayload_auditlog.authenticationInfo.principalEmail as actor,
    protopayload_auditlog.methodName as action,
    protopayload_auditlog.resourceName as resource,
    IF(ARRAY_LENGTH(protopayload_auditlog.authenticationInfo.serviceAccountDelegationInfo) > 0,
      protopayload_auditlog.authenticationInfo.serviceAccountDelegationInfo[SAFE_OFFSET(0)].firstPartyPrincipal.principalEmail,
      NULL
    ) AS impersonated_by
  FROM `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_*`
  WHERE
    timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
    AND protopayload_auditlog.authenticationInfo.principalEmail IS NOT NULL
    -- Actor to be investigated
    AND protopayload_auditlog.authenticationInfo.principalEmail IN (
      "[MY_COMPROMISED_SA]@[MY_PROJECT_ID].iam.gserviceaccount.com"
    )
)
SELECT
  day,
  actor, impersonated_by, action,
  ARRAY_AGG(DISTINCT resource IGNORE NULLS) AS resources,
  count(*) AS counter,
  MIN(timestamp) as earliest_timestamp,
  MAX(timestamp) as latest_timestamp
FROM actions
GROUP BY
  day, actor, action, impersonated_by
ORDER BY
  latest_timestamp DESC