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
  MAX(timestamp) as last_seen,
  MIN(timestamp) as first_seen,
  protopayload_auditlog.authenticationInfo.principalEmail as user,
  CASE
    WHEN protopayload_auditlog.requestMetadata.callerSuppliedUserAgent LIKE "Mozilla/%" THEN 'Cloud Console'
    WHEN protopayload_auditlog.requestMetadata.callerSuppliedUserAgent LIKE "google-cloud-sdk gcloud/%" THEN 'gcloud CLI'
    WHEN protopayload_auditlog.requestMetadata.callerSuppliedUserAgent LIKE "google-api-go-client/% Terraform/%" THEN 'Terraform'
    ELSE 'Other'
    END AS channel,
  protopayload_auditlog.requestMetadata.callerSuppliedUserAgent as user_agent,
  protopayload_auditlog.requestMetadata.callerIp as ip,
FROM `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_data_access`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
  AND protopayload_auditlog.serviceName = "cloudresourcemanager.googleapis.com"
  AND protopayload_auditlog.methodName IN ("GetProject", "FindOrCreateOrganization")
GROUP BY
  user, user_agent, ip
HAVING
  channel = 'Cloud Console'
ORDER BY
  last_seen DESC;
