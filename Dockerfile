FROM stakater/base-alpine:3.7
LABEL maintainer "Hazim <hazim_malik@hotmail.com>"

ARG DEBIAN_FRONTEND=noninteractive
ARG FLUENTD_VERSION=1.2.0
# Do not split this into multiple RUN!
# Docker creates a layer for every RUN-Statement
# therefore an 'apk delete' has no effect

RUN apk update \
 && apk upgrade \
 && apk add --no-cache \
        ca-certificates \
        ruby ruby-irb \
 && apk add --no-cache --virtual .build-deps \
        build-base \
        ruby-dev wget gnupg \
 && update-ca-certificates \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install oj -v 2.18.3 \
 && gem install json -v 2.1.0 \
 && gem install fluentd -v ${FLUENTD_VERSION} \
 && apk del .build-deps \
 && rm -rf /var/cache/apk/* \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

# Create user
RUN addgroup fluentd && \
    adduser -S -G fluentd fluentd && \
    adduser -S -G fluentd sudo

# for log storage (maybe shared with host)
RUN mkdir -p /fluentd/log
# configuration/plugins path (default: copied from .)
RUN mkdir -p /fluentd/etc /fluentd/plugins

COPY fluent.conf /fluentd/etc/


# Make daemon service dir for fluentd and place file
# It will be started and maintained by the base image
RUN mkdir -p /etc/service/fluentd
ADD start.sh /etc/service/fluentd/run

ENV FLUENTD_OPT=""
ENV FLUENTD_CONF="fluent.conf"
EXPOSE 24224 5140

# Simulate CMD behavior via environment variable
ENV COMMAND "fluentd -c /fluentd/etc/${FLUENTD_CONF} -p /fluentd/plugins $FLUENTD_OPT"