FROM logstash:8.18.0

USER root

COPY ./config/ /usr/share/logstash/config/
COPY ./pipeline/ /usr/share/logstash/pipeline/

COPY ./scripts/setup_elastic_logstash.sh /tmp/
RUN chmod +x /tmp/setup_elastic_logstash.sh

USER logstash
