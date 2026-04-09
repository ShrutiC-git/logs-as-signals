curl -X DELETE "http://localhost:9200/logs-demo"

curl -X PUT "http://localhost:9200/logs-demo" \
  -H "Content-Type: application/json" \
  -d '{
    "mappings": {
      "properties": {
        "service":      { "type": "keyword" },
        "endpoint":     { "type": "keyword" },
        "dependency":   { "type": "keyword" },        // e.g. "payment-service"
        "error":        { "type": "keyword" },        // e.g. "Payment Service Unavailable"
        "error_type":   { "type": "keyword" },        // e.g. "DEPENDENCY_FAILURE"
        "status":       { "type": "keyword" },        // "success" / "error"
        "region":       { "type": "keyword" },        // e.g. "eu-west-1" (optional but nice)
        "latency_ms":   { "type": "integer" },
        "retry_count":  { "type": "integer" },
        "@timestamp":   { "type": "date" }
      }
    }
  }'