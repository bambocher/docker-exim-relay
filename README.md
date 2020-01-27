# Exim Relay Docker Image


[Exim](http://exim.org/) relay [Docker](https://docker.com/) image based on [Alpine](https://alpinelinux.org/) Linux and support DKIM.

## [Docker Run](https://docs.docker.com/engine/reference/run)

Create docker volume for dkim keys:

```shell
docker volume create --name=smtp-dkim
```

Create docker container:

```shell
docker run \
    -d \
    --name smtp \
    --restart=always \
    -u exim \
    -p 25:25 \
    -v smtp-dkim:/dkim \
    -h mail.example.com \
    -e DKIM_DOMAINS=example.com \
    versh23/exim-relay
```

## [Docker Compose](https://docs.docker.com/compose/compose-file)

```yml
version: "2"
services:
  smtp:
    restart: always
    image: versh23/exim-relay
    user: exim
    ports:
      - "25:25"
    volumes:
      - smtp-dkim:/dkim
    hostname: mail.example.com
    environment:
      - RELAY_FROM_HOSTS=10.0.0.0/8:172.16.0.0/12:192.168.0.0/16
      - DKIM_KEY_SIZE=1024
      - DKIM_SELECTOR=dkim
      - DKIM_SIGN_HEADERS=Date:From:To:Subject:Message-ID
      - DKIM_DOMAINS=example.com
volumes:
  smtp-dkim:
    driver: local
```

## Reverse PTR

Create [Reverse PTR](https://en.wikipedia.org/wiki/Reverse_DNS_lookup) DNS record:

```
1.0.168.192.in-addr.arpa. 300 IN PTR mail.example.com.
```

## SPF

Create [SPF](http://openspf.org) DNS record:

```
example.com. 300 IN TXT "v=spf1 a mx -all"
```

## DKIM

Get dkim public key with docker exec:

```shell
docker exec -it smtp cat /dkim/example.com.pub
```

or get dkim public key with docker-compose exec:

```shell
docker-compose exec smtp cat /dkim/example.com.pub
```

or get dkim public key from docker volume:

```shell
sudo cat /var/lib/docker/volumes/smtp-dkim/_data/example.com.pub
```

Create [DKIM](http://dkim.org) DNS record:

```
dkim._domainkey.example.com. 300 IN TXT "v=DKIM1; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCqGPU5V6weixC6zPq+muZ2q0F7VkAfIV37ZjmZIK0Y0Kiz7ZiBIOjcVS958ncFnyqleSroqPV7ftgAykbxkIX/Rnq58VkxsCk7vO0nav0/cF0VlTP7/Pxe2PO4BYRW53rWUI6iOi7Y49q/1zWgcEa+fqc8FUqFvDebKtkeQy84BwIDAQAB"
```

## Debug

Print a count of the messages in the queue:

```shell
docker exec -it smtp exim -bpc
```

Print a listing of the messages in the queue (time queued, size, message-id, sender, recipient):

```shell
docker exec -it smtp exim -bp
```

Remove all frozen messages:

```shell
docker exec -it smtp exim -bpu | grep frozen | awk {'print $3'} | xargs exim -Mrm
```

Test how exim will route a given address:

```shell
docker exec -it smtp exim -bt test@gmail.com
```

```
test@gmail.com
  router = dnslookup, transport = remote_smtp
  host gmail-smtp-in.l.google.com      [64.233.164.27] MX=5
  host alt1.gmail-smtp-in.l.google.com [64.233.187.27] MX=10
  host alt2.gmail-smtp-in.l.google.com [173.194.72.27] MX=20
  host alt3.gmail-smtp-in.l.google.com [74.125.25.27]  MX=30
  host alt4.gmail-smtp-in.l.google.com [74.125.198.27] MX=40
```

Display all of Exim's configuration settings:

```shell
docker exec -it smtp exim -bP
```

View a message's headers:

```shell
docker exec -it smtp exim -Mvh <message-id>
```

View a message's body:

```shell
docker exec -it smtp exim -Mvb <message-id>
```

View a message's logs:

```shell
docker exec -it smtp exim -Mar <message-id>
```

Remove a message from the queue:

```shell
docker exec -it smtp exim -Mrm <message-id> [ <message-id> ... ]
```

Send a message:

```shell
echo "Test message" | mailx -v -r "sender@example.com" -s "Test subject" -S smtp="localhost:25" recipient@example.com
```

## License

[The MIT License](LICENSE)
