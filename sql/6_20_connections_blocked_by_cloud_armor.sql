SELECT
    timestamp,
    httpRequest.remoteIp,
    httpRequest.requestMethod,
    httpRequest.status,jsonpayload_type_loadbalancerlogentry.enforcedsecuritypolicy.name,
    resource.labels.backend_service_name,
    httpRequest.requestUrl,
  FROM `[MY_DATASET_ID].[MY_PROJECT_ID].requests`
  WHERE
    timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
    AND resource.type="http_load_balancer"
    AND jsonpayload_type_loadbalancerlogentry.statusdetails = "denied_by_security_policy"
  ORDER BY
    timestamp DESC