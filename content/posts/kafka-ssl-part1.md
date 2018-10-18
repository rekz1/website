---
title: "Kafka Security - Part 1 SSL Encryption"
date: 2018-10-17T07:00:00+02:00
tags: ["kafka", "security"]
categories: ["blog"]
---

When you talk about SSL and Kafka you have to distinguish between SSL encryption and 
SSL authentication.

This blog post is all about SSL encryption.

So the first step is to generate a new truststore and an associated private key.

Let's create first the private key and certificate.

## certificate private key
You will be prompted for:

- A password for the private key. Remember this.
- Information about you and your company.

Please note that in the time of writing CN is currently not important for Kafka. This may change.

```bash
$ openssl req -new -x509 -keyout ca-key -out ca-cert -days 365
```

This will create two files.

- ca-key 
    - The private key used later.
- ca-cert
    - The certificate that will be stored in the truststore.
    - It serves as the certificate authority (CA).
    - You can delete if after it has been stored in the truststore. It
    can be retrieved via `$ keytool -keystore kafka.truststore.jks -export -alias CARoot -rfc`

Next we will generate a new trust store from the certificate.

## create truststore
You will be prompted for:

- A password for the truststore. Remember this.
- A confirmation that you want to trust this certificate.

```bash
$ keytool -keystore kafka.truststore.jks -alias CARoot -import -file ca-cert
```

It outputs `Certificate was added to keystore`.

You can now safely delete the `ca-cert` file because it's in the truststore.

Now you have to generate a new keystore.

## create keystore
It is important to mention that each broker and each logical client need its own
keystore.

If you need multiple keystore just run this command multiple times.

You will be prompted for:

- A password for the keystore. Remember this.
- Personal information.

```bash
$ keytool -keystore kafka.keystore.jks -alias localhost -validity 365 -genkey -keyalg RSA
```

The keystore `kafka.keystore.jks` now contains a key pair and a self-signed certificate. 
Again, this keystore can only be used for one broker or one logical client.

## sign certificate
First we have to export the certificate from the truststore and storing it in `ca-cert`.

```bash
$ keytool -keystore kafka.truststore.jks -export -alias CARoot -rfc -file ca-cert
```

Next will be requesting the keystore to sign the certificate.
```bash
$ keytool -keystore kafka.keystore.jks -alias localhost -certreq -file cert-file
```

Now the truststore's private key (CA) will sign the keystore's certificate

```bash
$ openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file -out cert-signed -days 365 -CAcreateserial
```

The certificate that services as a CA will be imported into the keystore.

```bash
$ keytool -keystore kafka.keystore.jks -alias CARoot -import -file ca-cert
```

Next we have to import the signed certificate back into the keystore.

```bash
$ keytool -keystore kafka.keystore.jks -alias localhost -import -file cert-signed
```

You can now safely delete:

- cert-signed
  -  The keystore's certificate, signed by the CA, and stored back
- ca-cert.srl 
  - CA serial number
- cert-file
  - The keystore's certificate signing request
- ca-cert
  - The truststore cert because it's stored in the truststore  

The Kafka broker needs beside the keystore and truststore multiple credentials files.

## create _creds files
For `ca-key`, `kafka.keystore.jks` and `kafka.truststore.jks` we have to create files
where Kafka can find the password you used for creation.

```bash
$ echo "<your-password>" > ca_key_creds
$ echo "<your-password>" > keystore_creds
$ echo "<your-password>" > truststore_creds
```

## start Kafka

Ok, let's spin this shit up!

```yaml
broker:
    image: confluentinc/cp-kafka:4.0.1
    hostname: broker
    container_name: broker
    depends_on:
    - zookeeper
    ports:
    - "9092:9092"
    - "9093:9093"
    - "29092:29092"
    volumes:
    - $PWD/kafka-secrets/:/etc/kafka/secrets/
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: 'zookeeper:2181'
      KAFKA_LISTENERS: 'SSL://broker:9093'
      KAFKA_ADVERTISED_LISTENERS: 'SSL://broker:9093'
      KAFKA_SSL_KEY_CREDENTIALS: 'ca_key_creds'
      KAFKA_SSL_KEYSTORE_FILENAME: 'kafka.keystore.jks'
      KAFKA_SSL_KEYSTORE_CREDENTIALS: 'keystore_creds'
      KAFKA_SSL_TRUSTSTORE_FILENAME: 'kafka.truststore.jks'
      KAFKA_SSL_TRUSTSTORE_CREDENTIALS: 'truststore_creds'
      KAFKA_SECURITY_INTER_BROKER_PROTOCOL: 'SSL'
      KAFKA_SSL_CLIENT_AUTH: 'required'
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
```

## verify SSL config
You can verify your installation by running:

```bash
$ openssl s_client -connect localhost:9093
```

Till next time!

Chris