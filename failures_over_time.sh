curl -X POST "localhost:9200/logs-demo/_search?pretty" \
-H "Content-Type: application/json" \
-d '{
  "size": 0,
  "query": {
    "range": {
      "@timestamp": {
        "gte": "now-1m"
      }
    }
  },
  "aggs": {
    "status": {
      "terms": {
        "field": "status"
      }
    }
  }
}'