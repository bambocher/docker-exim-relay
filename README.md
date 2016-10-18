# Alpine Exim Relay Docker Container

[![GitHub Tag](https://img.shields.io/github/tag/bambocher/docker-exim-relay.svg)](https://registry.hub.docker.com/u/bambucha/exim-relay/)
[![Docker Stars](https://img.shields.io/docker/stars/bambucha/exim-relay.svg)](https://registry.hub.docker.com/u/bambucha/exim-relay/)
[![Layers](https://images.microbadger.com/badges/image/bambucha/exim-relay.svg)](https://microbadger.com/images/bambucha/exim-relay/)
[![Docker Pulls](https://img.shields.io/docker/pulls/bambucha/exim-relay.svg)](https://registry.hub.docker.com/u/bambucha/exim-relay/)
[![Docker Automated Build](https://img.shields.io/badge/automated-build-green.svg)](https://registry.hub.docker.com/u/bambucha/exim-relay/)
[![Docker License](https://img.shields.io/badge/license-MIT-green.svg)](https://registry.hub.docker.com/u/bambucha/exim-relay/)

## [Docker Run](https://docs.docker.com/engine/reference/run)

```shell
docker run -d \
	--name smtp \
	--restart=always \
	-p 25:25 \
	-v $(pwd)/dkim:/srv \
	-h mail.example.com \
    -e DKIM_DOMAINS=example.com \
	bambucha/exim-relay
```

## [Docker Compose](https://docs.docker.com/compose/compose-file)

```yml
version: "2"
services:
  app:
    restart: always
    links:
      - smtp
  smtp:
    restart: always
    image: bambucha/exim-relay
    volumes:
      - ./dkim:/srv
    hostname: mail.example.com
    environment:
      - RELAY_FROM_HOSTS=10.0.0.0/8:172.16.0.0/12:192.168.0.0/16
      - DKIM_KEY_SIZE=1024
      - DKIM_SELECTOR=dkim
      - DKIM_SIGN_HEADERS=Date:From:To:Subject:Message-ID
      - DKIM_DOMAINS=example.com
```

## [Reverse PTR](https://en.wikipedia.org/wiki/Reverse_DNS_lookup)

```
1.0.168.192.in-addr.arpa. 300 IN PTR mail.example.com.
```

## [MX](https://en.wikipedia.org/wiki/MX_record)

```
example.com. 10 MX mail.example.com
```

## [SPF](http://openspf.org)

```
example.com. 300 IN TXT "v=spf1 a mx -all"
```

## [DKIM](http://dkim.org)

```
cat ./dkim/example.com.pub
```

```
dkim._domainkey.example.com. 300 IN TXT "v=DKIM1; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCqGPU5V6weixC6zPq+muZ2q0F7VkAfIV37ZjmZIK0Y0Kiz7ZiBIOjcVS958ncFnyqleSroqPV7ftgAykbxkIX/Rnq58VkxsCk7vO0nav0/cF0VlTP7/Pxe2PO4BYRW53rWUI6iOi7Y49q/1zWgcEa+fqc8FUqFvDebKtkeQy84BwIDAQAB"
```

## [DMARK](https://dmarc.org)

## License

[The MIT License](LICENSE)
