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
  protopayload_auditlog.methodName,
  protopayload_auditlog.resourceName,
  (SELECT JSON_VALUE(x, '$.value')
   FROM UNNEST(JSON_QUERY_ARRAY(protopayload_auditlog.metadataJson, '$.event[0].parameter')) AS x
   WHERE JSON_VALUE(x, '$.name') = "USER_EMAIL") AS userEmail,
  (SELECT JSON_VALUE(x, '$.value')
   FROM UNNEST(JSON_QUERY_ARRAY(protopayload_auditlog.metadataJson, '$.event[0].parameter')) AS x
   WHERE JSON_VALUE(x, '$.name') = "GROUP_EMAIL") AS groupEmail,
FROM `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_activity`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 120 DAY)
  AND protopayload_auditlog.serviceName = "admin.googleapis.com"
  AND protopayload_auditlog.methodName = "google.admin.AdminService.addGroupMember"
  AND EXISTS(
    SELECT * FROM UNNEST(JSON_QUERY_ARRAY(protopayload_auditlog.metadataJson, '$.event[0].parameter')) AS x
    WHERE
      JSON_VALUE(x, '$.name') = 'GROUP_EMAIL'
      AND REGEXP_CONTAINS(JSON_VALUE(x, '$.value'), r'[admin|prod].*') -- Update regexp with other sensitive groups if applicable
  )