curl -X POST "localhost:9200/logs-demo/_search?pretty" \
-H "Content-Type: application/json" \
-d '{
    "size": 0,
    "query": {
        "bool": {
            "filter": [
                {
                    "range": {
                        "@timestamp": {
                            "from": "now-1m",
                            "to": null,
                            "include_lower": true,
                            "include_upper": true,
                            "boost": 1
                        }
                    }
                },
                {
                    "term": {
                        "service": {
                            "value": "checkout",
                            "boost": 1
                        }
                    }
                }
            ],
            "adjust_pure_negative": true,
            "boost": 1
        }
    },
    "aggregations": {
        "total_requests": {
            "value_count": {
                "field": "status"
            }
        },
        "status": {
            "terms": {
                "field": "status",
                "size": 10,
                "min_doc_count": 1,
                "shard_min_doc_count": 0,
                "show_term_doc_count_error": false,
                "order": [
                    {
                        "_count": "desc"
                    },
                    {
                        "_key": "asc"
                    }
                ]
            }
        },
        "by_dependency": {
            "terms": {
                "field": "dependency",
                "size": 10,
                "min_doc_count": 1,
                "shard_min_doc_count": 0,
                "show_term_doc_count_error": false,
                "order": [
                    {
                        "_count": "desc"
                    },
                    {
                        "_key": "asc"
                    }
                ]
            },
            "aggregations": {
                "errors": {
                    "terms": {
                        "field": "error_type",
                        "size": 10,
                        "min_doc_count": 1,
                        "shard_min_doc_count": 0,
                        "show_term_doc_count_error": false,
                        "order": [
                            {
                                "_count": "desc"
                            },
                            {
                                "_key": "asc"
                            }
                        ]
                    }
                }
            }
        }
    }
}'