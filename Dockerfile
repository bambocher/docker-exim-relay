FROM alpine:edge
MAINTAINER Dmitry Prazdnichnov <dp@bambucha.org>

ENV RELAY_FROM_HOSTS 10.0.0.0/8:172.16.0.0/12:192.168.0.0/16
ENV DKIM_KEY_SIZE 1024
ENV DKIM_SELECTOR dkim
ENV DKIM_SIGN_HEADERS Date:From:To:Subject:Message-ID
ENV DKIM_DOMAINS example.com
ENV REPOSITORY http://dl-cdn.alpinelinux.org/alpine/edge/testing

RUN apk --no-cache --repository $REPOSITORY add exim && mkdir /usr/lib/exim

COPY exim.conf /etc/exim/exim.conf
COPY entrypoint.sh /entrypoint.sh

VOLUME ["/srv"]
EXPOSE 25

ENTRYPOINT ["/entrypoint.sh"]
CMD ["-bd", "-q15m"]
