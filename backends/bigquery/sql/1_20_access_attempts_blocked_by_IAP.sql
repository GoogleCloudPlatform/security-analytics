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
  httpRequest.remoteIp,
  httpRequest.requestMethod,
  httpRequest.status,
  resource.labels.backend_service_name,
  httpRequest.requestUrl,
FROM `[MY_DATASET_ID].[MY_PROJECT_ID].requests`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
  AND resource.type="http_load_balancer"
  AND jsonpayload_type_loadbalancerlogentry.statusdetails = "handled_by_identity_aware_proxy"
ORDER BY
  timestamp DESC