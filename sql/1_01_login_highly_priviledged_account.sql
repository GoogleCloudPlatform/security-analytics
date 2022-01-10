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
  protopayload_auditlog.requestMetadata.callerIp,
  JSON_EXTRACT(protopayload_auditlog.metadataJson, "$.event[0].parameter[0].value") AS loginType
FROM `[MY_DATASET_ID].[MY_PROJECT_ID].cloudaudit_googleapis_com_data_access`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY)
  AND protopayload_auditlog.authenticationInfo.principalEmail LIKE "admin%"
  AND protopayload_auditlog.serviceName = "login.googleapis.com"
  AND protopayload_auditlog.methodName LIKE "google.login.LoginService.%"