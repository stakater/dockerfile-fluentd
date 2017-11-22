FROM stakater/base-alpine:3.6

LABEL maintainer "Asim <asim@aurorasolutions.com>"

LABEL Description="Fluentd docker image" Vendor="Stakater" Version="0.1"

ENV DUMB_INIT_VERSION=1.2.0

ENV SU_EXEC_VERSION=0.2

ARG DEBIAN_FRONTEND=noninteractive

RUN apk update \
 && apk upgrade \
 && apk add --no-cache \
        ca-certificates \
        ruby ruby-irb \
        su-exec==${SU_EXEC_VERSION}-r0 \
        dumb-init==${DUMB_INIT_VERSION}-r0 \
 && apk add --no-cache --virtual .build-deps \
        build-base \
        ruby-dev wget gnupg \
 && update-ca-certificates \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install fluentd -v 0.12.34 \
 && gem install oj \
 && gem install json \
 && gem install fluent-plugin-concat -v 1.0.0 \
 && gem install fluent-plugin-elasticsearch -v 1.9.3 \
 && gem install fluent-plugin-parser -v 0.6.1 \
 && apk del .build-deps \
 && rm -rf /var/cache/apk/* \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

# for log storage (maybe shared with host)
RUN mkdir -p /fluentd/log
# configuration/plugins path (default: copied from .)
RUN mkdir -p /fluentd/etc /fluentd/plugins

COPY fluent.conf /fluentd/etc/
COPY entrypoint.sh /bin/
RUN chmod +x /bin/entrypoint.sh


ENV FLUENTD_OPT=""
ENV FLUENTD_CONF="fluent.conf"

ENV LD_PRELOAD=""
ENV DUMB_INIT_SETSID 0

EXPOSE 24224 5140

ENTRYPOINT ["fluentd"]

CMD -c /fluentd/etc/${FLUENTD_CONF}