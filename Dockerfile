FROM alpine:edge
MAINTAINER Dmitry Prazdnichnov <dp@bambucha.org>

ENV RELAY_FROM_HOSTS=10.0.0.0/8:172.16.0.0/12:192.168.0.0/16 \
    DKIM_KEY_SIZE=1024 \
    DKIM_SELECTOR=dkim \
    DKIM_SIGN_HEADERS=Date:From:To:Subject:Message-ID \
    DKIM_DOMAINS=example.com \
    REPOSITORY=http://dl-cdn.alpinelinux.org/alpine/edge/testing

RUN apk --no-cache --repository $REPOSITORY add exim libcap \
    && mkdir /dkim /var/log/exim /usr/lib/exim /var/spool/exim \
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
