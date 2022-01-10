DECLARE
 TargetIP STRING;
SET
 TargetIP = "XXX.XXX.XXX.XXX";

SELECT
  TargetIP,
  COUNT(*) AS VistTimes
FROM
 `[MY_PROJECT_ID].[MY_DATASET_ID].compute_googleapis_com_vpc_flows`
WHERE
  timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY)
  AND jsonPayload.connection.dest_ip = TargetIP