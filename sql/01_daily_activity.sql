SELECT
  date_format(from_unixtime(CAST(timestamp AS BIGINT)), 'yyyy-MM-dd') AS event_date,
  COUNT(1) AS event_cnt,
  COUNT(DISTINCT user_id) AS active_user_cnt,
  COUNT(DISTINCT item_id) AS active_item_cnt,
  SUM(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) AS buy_event_cnt,
  ROUND(SUM(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) / COUNT(1), 4) AS buy_rate
FROM user_behavior
GROUP BY date_format(from_unixtime(CAST(timestamp AS BIGINT)), 'yyyy-MM-dd')
ORDER BY event_date;