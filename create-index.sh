curl -X PUT "localhost:9200/logs-demo" \
-H "Content-Type: application/json" \
-d '{
  "mappings": {
    "properties": {
      "service": { "type": "keyword" },
      "endpoint": { "type": "keyword" },
      "error": { "type": "keyword" },
      "status": { "type": "keyword" },
      "latency_ms": { "type": "integer" },
      "retry_count": { "type": "integer" },
      "@timestamp": { "type": "date" }
    }
  }
}'