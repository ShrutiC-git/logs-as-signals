## Alerting in OpenSearch Dashboard

#### Extraction Query:

```shell{
  "size": 0,
  "query": {
    "range": {
      "@timestamp": {
        "gte": "now-5m"
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
}
```

#### Trigger: 
```
def failures = 0;
def total = 0;

for (bucket in ctx.results[0].aggregations.status.buckets) {
  total += bucket.doc_count;
  if (bucket.key == "error") {
    failures = bucket.doc_count;
  }
}

return total > 0 && (failures / total) > 0.2;
```

#### Channel:
 Custom Webhook

