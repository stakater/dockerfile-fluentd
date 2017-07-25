FROM fluent/fluentd:v0.14-debian

MAINTAINER Ahmad Iqbal Ali <ahmadiq@gmail.com>

ENV ELASTICSEARCH_HOST es-logging.default.svc

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends \
            ca-certificates \
            ruby \
 && buildDeps=" \
      make gcc g++ libc-dev \
      ruby-dev \
      wget bzip2 gnupg dirmngr \
    " \
 && apt-get install -y --no-install-recommends $buildDeps \
 && update-ca-certificates \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install fluent-plugin-kubernetes_metadata_filter -v 0.26.2 \
 && gem install fluent-plugin-elasticsearch -v 1.9.5 \
 && gem install fluent-plugin-prometheus -v 0.2.1 \
 && gem cleanup fluentd

COPY start-fluentd /bin/
RUN chmod +x /bin/start-fluentd

ENTRYPOINT ["/bin/start-fluentd"]
CMD fluentd -c /fluentd/etc/fluent.conf
