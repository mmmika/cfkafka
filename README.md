# Kafka SSL With CloudFlare SSL

This repo provides scripts to generate PKI infrastructure for Kafka with CFSSL, and then run Kafka in Docker Compose with these certificates.  There are three brokers, and one user certificate.

Generate the certificates:

```shell script
./generate.sh
```

Bring the cluster up:

```shell script
docker-compose up
```

Produce and consume:

```shell script
docker-compose exec kafka-1 kafka-console-producer  --broker-list localhost:19092 --topic ssl-topic --producer.config /etc/kafka/secrets/ssl.config
docker-compose exec kafka-1 kafka-console-consumer  --bootstrap-server localhost:19092 --topic ssl-topic --consumer.config /etc/kafka/secrets/ssl.config
```

Take the cluster down:

```shell script
docker-compose down -v
```

Remove all the certificates:

```shell script
./clean.sh
```