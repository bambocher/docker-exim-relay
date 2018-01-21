ARG ALPINE_VERSION=3.7

FROM alpine:$ALPINE_VERSION
MAINTAINER Dmitry Prazdnichnov <dp@bambucha.org>

ARG EXIM_VERSION=4.89.1-r0

ARG DKIM_DOMAINS=domain.tld
ARG RELAY_FROM_HOSTS=10.0.0.0/8:172.16.0.0/12:192.168.0.0/16
ARG DKIM_KEY_SIZE=1024
ARG DKIM_SELECTOR=dkim
ARG DKIM_SIGN_HEADERS=Date:From:To:Subject:Message-ID

LABEL org.label-schema.version=${EXIM_VERSION} \
      org.label-schema.vcs-url=https://github.com/bambocher/docker-exim-relay \
      org.label-schema.license=MIT \
      org.label-schema.schema-version=1.0

ENV RELAY_FROM_HOSTS=${RELAY_FROM_HOSTS} \
    DKIM_DOMAINS=${DKIM_DOMAINS} \
    DKIM_KEY_SIZE=${DKIM_KEY_SIZE} \
    DKIM_SELECTOR=${DKIM_SELECTOR} \
    DKIM_SIGN_HEADERS=${DKIM_SIGN_HEADERS}

RUN apk --no-cache add exim=${EXIM_VERSION} libcap openssl \
    && mkdir -p /dkim /var/log/exim /usr/lib/exim /var/spool/exim \
    && ln -s /dev/stdout /var/log/exim/main \
    && ln -s /dev/stderr /var/log/exim/panic \
    && ln -s /dev/stderr /var/log/exim/reject \
    && chown -R exim: /dkim /var/log/exim /usr/lib/exim /var/spool/exim \
    && chmod 0755 /usr/sbin/exim \
    && setcap cap_net_bind_service=+ep /usr/sbin/exim \
    && apk del libcap

COPY ./entrypoint.sh /
COPY ./exim.conf /etc/exim

USER exim
VOLUME ["/dkim"]
EXPOSE 25

ENTRYPOINT ["/entrypoint.sh"]
CMD ["-bdf", "-q15m"]
