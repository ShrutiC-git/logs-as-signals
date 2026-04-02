curl -X POST "localhost:9200/logs-demo/_search?pretty" \
-H "Content-Type: application/json" \
-d '{
  "size": 0,
  "aggs": {
    "requests_over_time": {
      "date_histogram": {
        "field": "@timestamp",
        "fixed_interval": "5s"
      }
    }
  }
}'