FROM fabric8/fluentd:0.14.8

LABEL maintainer "Asim <asim@aurorasolutions.com>"

LABEL Description="Fluentd docker image" Vendor="Stakater" Version="0.1"

ENV ELASTICSEARCH_HOST es-logging.default.svc

RUN touch /var/lib/rpm/* && yum install -y gcc-c++ && yum clean all

RUN scl enable rh-ruby23 'gem install --no-document fluent-plugin-kubernetes_metadata_filter -v 0.26.2' && \
    scl enable rh-ruby23 'gem install --no-document fluent-plugin-elasticsearch -v 1.9.5' && \
    scl enable rh-ruby23 'gem install --no-document fluent-plugin-prometheus -v 0.2.1' && \
    scl enable rh-ruby23 'gem cleanup fluentd'

COPY ./start-fluentd.sh /opt

RUN chmod +x /opt/start-fluentd.sh

ENTRYPOINT ["/bin/bash", "-c", "/opt/start-fluentd.sh"]
