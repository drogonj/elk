#!/bin/sh

if [ -z "$ELASTIC_PASSWORD" ] || [ -z "$KIBANA_SYSTEM_PASSWORD" ]; then
  echo "Error: Required environment variables (ELASTIC_PASSWORD, KIBANA_SYSTEM_PASSWORD) are not set."
  exit 1
fi

RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -u elastic:"${ELASTIC_PASSWORD}" -X POST \
    "http://elasticsearch:9200/_security/user/kibana_system/_password" \
    -H "Content-Type: application/json" -d \
    "{ \"password\": \"${KIBANA_SYSTEM_PASSWORD}\" }")

if [ "$RESPONSE" -ne 200 ]; then
  echo "Error: Failed to update the Kibana system password. HTTP code: $RESPONSE"
  exit 1
else
  echo "Kibana system password updated successfully."
fi

exec /usr/local/bin/kibana-docker