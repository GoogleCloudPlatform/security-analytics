SELECT
  *,
  AVG(counter) OVER (
    PARTITION BY principalEmail
    ORDER BY day
    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS avg,
  STDDEV(counter) OVER (
    PARTITION BY principalEmail
    ORDER BY day
    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS stddev,
  COUNT(*) OVER (
    PARTITION BY principalEmail
    RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS numSamples
FROM (
  SELECT
    protopayload_auditlog.authenticationInfo.principalEmail,
    EXTRACT(DATE FROM timestamp) AS day,
    ARRAY_AGG(DISTINCT protopayload_auditlog.methodName IGNORE NULLS) AS actions,
    COUNT(*) AS counter
  FROM `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_*`
  WHERE
    timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY)
    AND protopayload_auditlog.authenticationInfo.principalEmail IS NOT NULL
    AND protopayload_auditlog.methodName NOT LIKE "storage.%.get"
    AND protopayload_auditlog.methodName NOT LIKE "v1.compute.%.list"
    AND protopayload_auditlog.methodName NOT LIKE "beta.compute.%.list"
  GROUP BY
    protopayload_auditlog.authenticationInfo.principalEmail,
    day
)
WHERE TRUE
QUALIFY
  counter > avg + 3 * stddev
  AND day >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) 
ORDER BY
  counter DESC