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
      PARTITION BY principal_email
      ORDER BY day
      ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS avg,
    STDDEV(counter) OVER (
      PARTITION BY principal_email
      ORDER BY day
      ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS stddev,
    COUNT(*) OVER (
      PARTITION BY principal_email
      RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS numSamples
  FROM (
    SELECT
      proto_payload.audit_log.authentication_info.principal_email,
      EXTRACT(DATE FROM timestamp) AS day,
      ARRAY_AGG(DISTINCT proto_payload.audit_log.method_name IGNORE NULLS) AS actions,
      COUNT(*) AS counter
    FROM `[MY_PROJECT_ID].[MY_LOG_BUCKET_REGION].[MY_LOG_BUCKET_NAME]._AllLogs`
    WHERE
      timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY)
      AND proto_payload.audit_log.authentication_info.principal_email IS NOT NULL
      AND proto_payload.audit_log.method_name NOT LIKE "storage.%.get"
      AND proto_payload.audit_log.method_name NOT LIKE "v1.compute.%.list"
      AND proto_payload.audit_log.method_name NOT LIKE "beta.compute.%.list"
    GROUP BY
      proto_payload.audit_log.authentication_info.principal_email,
      day
  )
)
WHERE
  counter > avg + 3 * stddev
  AND day >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) 
ORDER BY
  counter DESC
