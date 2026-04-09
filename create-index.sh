curl -X DELETE "http://localhost:9200/logs-demo"

curl -X PUT "http://localhost:9200/logs-demo" \
  -H "Content-Type: application/json" \
  -d '{
    "mappings": {
      "properties": {
        "service":      { "type": "keyword" },        // e.g. "checkout"
        "endpoint":     { "type": "keyword" },        // e.g. "/checkout"
        "dependency":   { "type": "keyword" },        // e.g. "payment-service"
        "error":        { "type": "keyword" },        // e.g. "Payment Service Unavailable"
        "error_type":   { "type": "keyword" },        // e.g. "DEPENDENCY_FAILURE"
        "status":       { "type": "keyword" },        // e.g. "success" / "error"
        "region":       { "type": "keyword" },        // e.g. "eu-west-1" (optional but nice)
        "latency_ms":   { "type": "integer" },        // e.g. 120
        "retry_count":  { "type": "integer" },        // e.g. 0
        "@timestamp":   { "type": "date" }            // e.g. "2026-03-19T10:00:00Z"
      }
    }
  }'