curl -X POST "localhost:9200/logs-demo/_doc" \
-H "Content-Type: application/json" \
-d '{
  "service": "checkout",
  "endpoint": "/checkout",
  "latency_ms": 120,
  "error": "",
  "retry_count": 0,
  "status": "success",
  "@timestamp": "2026-03-19T10:00:00Z"
}'
