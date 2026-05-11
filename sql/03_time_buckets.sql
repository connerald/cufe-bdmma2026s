WITH bucketed AS (
  SELECT
    CASE
      WHEN hour(from_unixtime(CAST(timestamp AS BIGINT))) BETWEEN 0 AND 5 THEN '00-05'
      WHEN hour(from_unixtime(CAST(timestamp AS BIGINT))) BETWEEN 6 AND 11 THEN '06-11'
      WHEN hour(from_unixtime(CAST(timestamp AS BIGINT))) BETWEEN 12 AND 17 THEN '12-17'
      ELSE '18-23'
    END AS time_bucket,
    CASE
      WHEN hour(from_unixtime(CAST(timestamp AS BIGINT))) BETWEEN 0 AND 5 THEN 1
      WHEN hour(from_unixtime(CAST(timestamp AS BIGINT))) BETWEEN 6 AND 11 THEN 2
      WHEN hour(from_unixtime(CAST(timestamp AS BIGINT))) BETWEEN 12 AND 17 THEN 3
      ELSE 4
    END AS bucket_order
  FROM user_behavior
)
SELECT
  time_bucket,
  COUNT(1) AS event_cnt,
  ROUND(COUNT(1) / SUM(COUNT(1)) OVER (), 4) AS event_share
FROM bucketed
GROUP BY time_bucket, bucket_order
ORDER BY bucket_order;