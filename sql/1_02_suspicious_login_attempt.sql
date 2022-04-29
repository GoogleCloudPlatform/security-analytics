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
  protopayload_auditlog.methodName
FROM `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_data_access`,
  UNNEST(JSON_QUERY_ARRAY(protopayload_auditlog.metadataJson, '$.event[0].parameter')) AS parameter
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY)
  AND protopayload_auditlog.metadataJson IS NOT NULL
  AND protopayload_auditlog.serviceName = "login.googleapis.com"
  AND protopayload_auditlog.methodName = "google.login.LoginService.loginSuccess"
  AND JSON_VALUE(parameter, '$.name') = "is_suspicious"
  AND JSON_VALUE(parameter, '$.boolValue') = "true"