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