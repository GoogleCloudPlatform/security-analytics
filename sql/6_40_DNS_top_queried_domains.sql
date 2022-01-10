SELECT
 jsonPayload.queryname,
 COUNT(jsonPayload.queryname) AS TotalQueries
FROM
 `[MY_DATASET_ID].[MY_PROJECT_ID].dns_googleapis_com_dns_queries`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY)
GROUP BY
 jsonPayload.queryname
ORDER BY
 TotalQueries DESC
LIMIT
 10