#!/bin/bash

BASE_URL="http://localhost:8080"

echo "Sending normal traffic..."

for i in {1..10}; do
  curl -s -o /dev/null -w "%{http_code}\n" $BASE_URL/checkout
  sleep 0.2
done

echo "Injecting failure (50% of requests will now fail)..."
curl -s "$BASE_URL/toggle-failure" > /dev/null

echo "Sending mixed traffic (~50% failure)..."

for i in {1..40}; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/checkout")
  echo "Request status: $status"
  sleep 0.5
done

echo "Done"