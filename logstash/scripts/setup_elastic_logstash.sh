#!/bin/sh

if [ -z "$ELASTIC_PASSWORD" ] || [ -z "$LOGSTASH_INTERNAL_PASSWORD" ] || [ -z "$LOGSTASH_WRITER_USERNAME" ] || [ -z "$LOGSTASH_WRITER_PASSWORD" ]; then
  echo "Error: Required environment variables (ELASTIC_PASSWORD, LOGSTASH_INTERNAL_PASSWORD, LOGSTASH_WRITER_USERNAME, LOGSTASH_WRITER_PASSWORD) are not set."
  exit 1
fi

echo "Trying to update logstash_system password in elasticsearch..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -u elastic:"${ELASTIC_PASSWORD}" -X POST \
    "http://elasticsearch:9200/_security/user/logstash_system/_password" \
    -H "Content-Type: application/json" -d \
    "{\"password\": \"${LOGSTASH_INTERNAL_PASSWORD}\" }")

if [ "$RESPONSE" -ne 200 ]; then
  echo "Error: Failed to update the Logstash system password. HTTP code: $RESPONSE"
  exit 1
else
  echo "Logstash system password updated successfully."
fi

echo "Updating the logstash_writer role in elasticsearch..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -u elastic:"${ELASTIC_PASSWORD}" -X POST \
  "http://elasticsearch:9200/_security/role/logstash_writer_role" \
  -H "Content-Type: application/json" -d \
  "{ \
    \"cluster\": [\"monitor\", \"manage_index_templates\"], \
    \"indices\": [ \
      { \
        \"names\": [\"logstash-*\", \"logs-*\"], \
        \"privileges\": [\"create_index\", \"write\", \"delete\", \"index\", \"manage\", \"auto_configure\"] \
      } \
    ] \
  }")

if [ "$RESPONSE" -ne 200 ]; then
  echo "Error: Failed to update the logstash_writer role. HTTP code: $RESPONSE"
  exit 1
else
  echo "logstash_writer role updated successfully."
fi

echo "Trying to create user ${LOGSTASH_WRITER_USERNAME} in elasticsearch..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -u elastic:"${ELASTIC_PASSWORD}" -X PUT \
    "http://elasticsearch:9200/_security/user/${LOGSTASH_WRITER_USERNAME}" \
    -H "Content-Type: application/json" -d \
    "{ \
      \"password\": \"${LOGSTASH_WRITER_PASSWORD}\", \
      \"roles\": [\"logstash_writer_role\"], \
      \"full_name\": \"Logstash Writer User\", \
      \"enabled\": true \
    }")

if [ "$RESPONSE" -ne 200 ]; then
  echo "Error: Failed to update the Logstash system password. HTTP code: $RESPONSE"
  exit 1
else
  echo "${LOGSTASH_WRITER_USERNAME} created successfully."
fi

echo "Trying to create django-backend template index in elasticsearch..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -u ${LOGSTASH_WRITER_USERNAME}:"${LOGSTASH_WRITER_PASSWORD}" -X PUT \
  "http://elasticsearch:9200/_index_template/django-backend-template" \
  -H "Content-Type: application/json" -d \
  "{ \
    \"index_patterns\": [\"logs-*\"], \
    \"data_stream\": {}, \
    \"template\": { \
      \"settings\": { \
        \"number_of_shards\": 1, \
        \"number_of_replicas\": 0 \
      } \
    } \
  }")

if [ "$RESPONSE" -ne 200 ]; then
  echo "Error: Failed to create django-backend template index. HTTP code: $RESPONSE"
  exit 1
else
  echo "django-backend template index created successfully."
fi

bin/logstash-plugin list
bin/logstash-plugin update

exec /usr/local/bin/docker-entrypoint
