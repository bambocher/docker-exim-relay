#!/bin/ash

EXIM=/usr/sbin/exim
OPENSSL=/usr/bin/openssl

for domain in $DKIM_DOMAINS; do
    DKIM=/dkim/$domain
    if [ ! -f $DKIM ]; then
        $OPENSSL genrsa $DKIM_KEY_SIZE > $DKIM
    fi
    if [ ! -f $DKIM.pub ]; then
        $OPENSSL rsa -in $DKIM -pubout > $DKIM.pub
    fi
done

$EXIM $@
trap "kill $!" SIGINT SIGTERM
