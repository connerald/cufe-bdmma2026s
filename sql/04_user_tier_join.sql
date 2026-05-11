SELECT
  p.user_tier,
  COUNT(1) AS event_cnt,
  COUNT(DISTINCT b.user_id) AS user_cnt,
  SUM(CASE WHEN b.behavior_type = 'buy' THEN 1 ELSE 0 END) AS buy_event_cnt,
  ROUND(SUM(CASE WHEN b.behavior_type = 'buy' THEN 1 ELSE 0 END) / COUNT(1), 4) AS buy_rate,
  ROUND(AVG(p.total_events), 2) AS avg_profile_events,
  ROUND(AVG(p.buy_events), 2) AS avg_profile_buy_events,
  ROUND(AVG(p.active_days), 2) AS avg_active_days
FROM user_behavior b
JOIN user_profile p
  ON b.user_id = p.user_id
GROUP BY p.user_tier
ORDER BY CASE p.user_tier WHEN 'light' THEN 1 WHEN 'medium' THEN 2 ELSE 3 END;