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
  *
FROM (
  SELECT
    *,
    AVG(counter) OVER (
      ORDER BY day
      ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS avg,
    STDDEV(counter) OVER (
      ORDER BY day
      ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS stddev,
    COUNT(*) OVER (
      RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS numSamples
  FROM (
    SELECT
      EXTRACT(DATE FROM timestamp) AS day,
      ARRAY_AGG(DISTINCT proto_payload.audit_log.method_name IGNORE NULLS) AS actions,
      ARRAY_AGG(DISTINCT proto_payload.audit_log.authentication_info.principal_email IGNORE NULLS) AS actors,
      COUNT(*) AS counter
    FROM `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`
    WHERE
      timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
      AND proto_payload.audit_log.method_name LIKE "v1.compute.firewalls.%"
      AND proto_payload.audit_log.method_name NOT IN ("v1.compute.firewalls.list", "v1.compute.firewalls.get")
    GROUP BY
      day
  )
)
WHERE
  counter > avg + 2 * stddev
  AND day >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) 
ORDER BY
  counter DESC
