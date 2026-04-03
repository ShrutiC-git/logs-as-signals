## Alerting in OpenSearch Dashboard

#### Extraction Query:

```shell{
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
    },
    "endpoint": {
      "terms": {
        "field": "endpoint"
      }
    },
    "errors": {
      "terms": {
        "field": "error"
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
 Custom Webhook: http://host.docker.internal:8080/alert

#### Adding Context to the Alert: 
```
🚨 Error Spike Detected

Service: {{ctx.monitor.name}}

Status Breakdown:
{{#ctx.results.0.aggregations.status.buckets}}
- {{key}} : {{doc_count}}
{{/ctx.results.0.aggregations.status.buckets}}

Endpoint:
{{#ctx.results.0.aggregations.endpoint.buckets}}
- {{key}} : {{doc_count}}
{{/ctx.results.0.aggregations.endpoint.buckets}}

Error Types:
{{#ctx.results.0.aggregations.errors.buckets}}
- {{key}} : {{doc_count}}
{{/ctx.results.0.aggregations.errors.buckets}}

Time Window:
{{ctx.periodStart}} → {{ctx.periodEnd}}```


