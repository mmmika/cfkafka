#!/usr/bin/env bash

PASSWORD="123456"

# Create dir
mkdir -p keys/

# Generate the CA
cfssl genkey -initca ca.json | cfssljson -bare keys/ca

# Generate broker keys
cfssl gencert -ca keys/ca.pem -ca-key keys/ca-key.pem broker-1.json | cfssljson -bare keys/broker-1
cfssl gencert -ca keys/ca.pem -ca-key keys/ca-key.pem broker-2.json | cfssljson -bare keys/broker-2
cfssl gencert -ca keys/ca.pem -ca-key keys/ca-key.pem broker-3.json | cfssljson -bare keys/broker-3

# Generate broker keys - ext
cfssl gencert -ca keys/ca.pem -ca-key keys/ca-key.pem broker-ext-1.json | cfssljson -bare keys/broker-ext-1
cfssl gencert -ca keys/ca.pem -ca-key keys/ca-key.pem broker-ext-2.json | cfssljson -bare keys/broker-ext-2
cfssl gencert -ca keys/ca.pem -ca-key keys/ca-key.pem broker-ext-3.json | cfssljson -bare keys/broker-ext-3

# Generate full chain broker CRTs
cat keys/broker-1.pem keys/ca.pem > keys/broker-1-full-chain.pem
cat keys/broker-2.pem keys/ca.pem > keys/broker-2-full-chain.pem
cat keys/broker-3.pem keys/ca.pem > keys/broker-3-full-chain.pem

# Generate full chain broker CRTs - ext
cat keys/broker-ext-1.pem keys/ca.pem > keys/broker-ext-1-full-chain.pem
cat keys/broker-ext-2.pem keys/ca.pem > keys/broker-ext-2-full-chain.pem
cat keys/broker-ext-3.pem keys/ca.pem > keys/broker-ext-3-full-chain.pem

# Generate user keys
cfssl gencert -ca keys/ca.pem -ca-key keys/ca-key.pem user1.json | cfssljson -bare keys/user1

# Convert CA to Java Keystore format (truststrore)
rm keys/truststore
keytool -importcert -keystore keys/truststore -storepass $PASSWORD -storetype JKS -alias ca -file keys/ca.pem -noprompt

# Convert keys to PKCS12
openssl pkcs12 -export -out keys/broker-1.p12 -in keys/broker-1-full-chain.pem -inkey keys/broker-1-key.pem -password pass:$PASSWORD
openssl pkcs12 -export -out keys/broker-ext-1.p12 -in keys/broker-ext-1-full-chain.pem -inkey keys/broker-ext-1-key.pem -password pass:$PASSWORD

openssl pkcs12 -export -out keys/broker-2.p12 -in keys/broker-2-full-chain.pem -inkey keys/broker-2-key.pem -password pass:$PASSWORD
openssl pkcs12 -export -out keys/broker-ext-2.p12 -in keys/broker-ext-2-full-chain.pem -inkey keys/broker-ext-2-key.pem -password pass:$PASSWORD

openssl pkcs12 -export -out keys/broker-3.p12 -in keys/broker-3-full-chain.pem -inkey keys/broker-3-key.pem -password pass:$PASSWORD
openssl pkcs12 -export -out keys/broker-ext-3.p12 -in keys/broker-ext-3-full-chain.pem -inkey keys/broker-ext-3-key.pem -password pass:$PASSWORD

openssl pkcs12 -export -out keys/user1.p12 -in keys/user1.pem -inkey keys/user1-key.pem -password pass:$PASSWORD

# Convert PKCS12 keys to keystores
rm keys/*.keystore
keytool -importkeystore -srckeystore keys/broker-1.p12 -srcstoretype PKCS12 -srcstorepass $PASSWORD -destkeystore keys/broker-1.keystore -deststoretype JKS -deststorepass $PASSWORD -noprompt
keytool -importkeystore -srckeystore keys/broker-ext-1.p12 -srcstoretype PKCS12 -srcstorepass $PASSWORD -destkeystore keys/broker-ext-1.keystore -deststoretype JKS -deststorepass $PASSWORD -noprompt

keytool -importkeystore -srckeystore keys/broker-2.p12 -srcstoretype PKCS12 -srcstorepass $PASSWORD -destkeystore keys/broker-2.keystore -deststoretype JKS -deststorepass $PASSWORD -noprompt
keytool -importkeystore -srckeystore keys/broker-ext-2.p12 -srcstoretype PKCS12 -srcstorepass $PASSWORD -destkeystore keys/broker-ext-2.keystore -deststoretype JKS -deststorepass $PASSWORD -noprompt

keytool -importkeystore -srckeystore keys/broker-3.p12 -srcstoretype PKCS12 -srcstorepass $PASSWORD -destkeystore keys/broker-3.keystore -deststoretype JKS -deststorepass $PASSWORD -noprompt
keytool -importkeystore -srckeystore keys/broker-ext-3.p12 -srcstoretype PKCS12 -srcstorepass $PASSWORD -destkeystore keys/broker-ext-3.keystore -deststoretype JKS -deststorepass $PASSWORD -noprompt

keytool -importkeystore -srckeystore keys/user1.p12 -srcstoretype PKCS12 -srcstorepass $PASSWORD -destkeystore keys/user1.keystore -deststoretype JKS -deststorepass $PASSWORD -noprompt

echo ${PASSWORD} > keys/creds

cat << EOF > keys/ssl.config
group.id=ssl-host
ssl.truststore.location=/etc/kafka/secrets/truststore
ssl.truststore.password=${PASSWORD}

ssl.keystore.location=/etc/kafka/secrets/user1.keystore
ssl.keystore.password=${PASSWORD}

ssl.key.password=${PASSWORD}
ssl.endpoint.identification.algorithm=

security.protocol=SSL
EOF