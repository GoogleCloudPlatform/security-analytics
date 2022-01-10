WITH actions AS(
SELECT
  timestamp,
  protopayload_auditlog.authenticationInfo.principalEmail,
  protopayload_auditlog.methodName,
  protopayload_auditlog.serviceName,
  protopayload_auditlog.resourceName,
  protopayload_auditlog.requestMetadata.callerIp,
FROM
 `[MY_PROJECT_ID].[MY_DATASET_ID].cloudaudit_googleapis_com_activity`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY)
  AND protopayload_auditlog.requestMetadata.callerIp IS NOT NULL
ORDER BY
  timestamp DESC
LIMIT 1000)

SELECT
  IF(MIN(timestamp) >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY), 1, 0) AS isUnusual,
  methodName,
  principalEmail,
  countryName,
  ARRAY_AGG(DISTINCT cityName IGNORE NULLS) AS cities,
  ARRAY_AGG(DISTINCT resourceName IGNORE NULLS) AS resources,
  MIN(timestamp) AS earliest,
  MAX(timestamp) AS latest,
FROM(
   SELECT
   t.*,
   locs.country_name AS countryName,
   locs.city_name AS cityName
   FROM (
   SELECT *, NET.SAFE_IP_FROM_STRING(callerIp) & NET.IP_NET_MASK(4, mask) network_bin
     FROM actions, UNNEST(GENERATE_ARRAY(9,32)) mask
   WHERE BYTE_LENGTH(NET.SAFE_IP_FROM_STRING(callerIp)) = 4
   ) AS t
   JOIN `fh-bigquery.geocode.201806_geolite2_city_ipv4_locs` AS locs
   USING (network_bin, mask)
)
GROUP BY
  methodName, principalEmail, countryName
ORDER BY 
  isUnusual DESC