SELECT
  category_id,
  COUNT(1) AS event_cnt,
  COUNT(DISTINCT user_id) AS active_user_cnt,
  SUM(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) AS buy_event_cnt,
  ROUND(SUM(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) / COUNT(1), 4) AS buy_rate
FROM user_behavior
GROUP BY category_id
ORDER BY buy_event_cnt DESC, event_cnt DESC, category_id
LIMIT 10;