curl -X GET "http://localhost:9200/logs-demo/_search?pretty=true" \
  -H "Content-Type: application/json" \
  -d '{
    "size": 1,
    "sort": [
      {
        "@timestamp": {
          "order": "desc"
        }
      }
    ],
    "query": {
      "match_all": {}
    }
  }'