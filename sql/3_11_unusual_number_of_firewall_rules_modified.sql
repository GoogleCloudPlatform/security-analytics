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
    ARRAY_AGG(DISTINCT protopayload_auditlog.methodName IGNORE NULLS) AS actions,
    ARRAY_AGG(DISTINCT protopayload_auditlog.authenticationInfo.principalEmail IGNORE NULLS) AS actors,
    COUNT(*) AS counter
  FROM `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_activity`
  WHERE
    timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
    AND protopayload_auditlog.methodName LIKE "v1.compute.firewalls.%"
    AND protopayload_auditlog.methodName NOT IN ("v1.compute.firewalls.list", "v1.compute.firewalls.get")
  GROUP BY
    day
)
WHERE TRUE
QUALIFY
  counter > avg + 2 * stddev
  AND day >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) 
ORDER BY
  counter DESC