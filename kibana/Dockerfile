FROM kibana:8.18.0

USER root

RUN apt update -y && \
    apt install curl -y

COPY ./config/ /usr/share/kibana/config/

COPY ./scripts/setup_elastic_kibana_password.sh /tmp/
RUN chmod +x /tmp/setup_elastic_kibana_password.sh

USER kibana
