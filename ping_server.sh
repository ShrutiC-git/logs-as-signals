#!/bin/bash

BASE_URL="http://localhost:8080"

echo "Sending normal traffic..."

for i in {1..10}; do
  curl -s -o /dev/null -w "%{http_code}" $BASE_URL/checkout
  echo
  sleep 0.2
done

echo "Injecting failure..."
curl -s $BASE_URL/toggle-failure > /dev/null

echo "Sending failure traffic... (toggle recovery to stop)"

while true; do
  status=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/checkout)

  echo "Request status: $status"

  if [ "$status" == "200" ]; then
    echo "Recovery detected. Stopping."
    break
  fi

  sleep 0.2
done

echo "Done"
