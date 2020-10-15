#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "Generate credentials and store in secrets"

echo "Generate TLS CA root certificate and private key"
TMP_CERT=$(mktemp)
openssl ecparam -name prime256v1 -genkey -noout -out $TMP_CERT-key.pem
openssl req -new -key $TMP_CERT-key.pem -config assets/tls-ca-root-cert.cnf -out $TMP_CERT.csr \
      -subj "/C=DE/ST=NRW/L=Paderborn/O=UC4/OU=UC4/CN=tls-ca"
openssl x509 -req -days 730 -in $TMP_CERT.csr -signkey $TMP_CERT-key.pem -out $TMP_CERT-cert.pem \
      -extensions v3_req -extfile assets/tls-ca-root-cert.cnf

small_sep

echo "Provide certificate and privkey as kubernetes secret"
kubectl create secret generic key.tls-ca -n hlf --from-file=key.pem=$TMP_CERT-key.pem
kubectl create secret generic cert.tls-ca -n hlf --from-file=cert.pem=$TMP_CERT-cert.pem

sep

echo "Generate Orderer Org root certificate and private key"
TMP_CERT=$(mktemp)
openssl ecparam -name prime256v1 -genkey -noout -out $TMP_CERT-key.pem
openssl req -new -key $TMP_CERT-key.pem -config assets/rca-org0-cert.cnf -out $TMP_CERT.csr \
      -subj "/C=DE/ST=NRW/L=Paderborn/O=UC4/OU=UC4/CN=tls-ca"
openssl x509 -req -days 730  -in $TMP_CERT.csr -signkey $TMP_CERT-key.pem -out $TMP_CERT-cert.pem \
      -extensions v3_req -extfile assets/rca-org0-cert.cnf

small_sep

echo "Provide certificate and privkey as kubernetes secret"
kubectl create secret generic key.rca-org0 -n hlf --from-file=key.pem=$TMP_CERT-key.pem
kubectl create secret generic cert.rca-org0 -n hlf --from-file=cert.pem=$TMP_CERT-cert.pem

sep

echo "Generate Org1 root certificate and private key"
TMP_CERT=$(mktemp)
openssl ecparam -name prime256v1 -genkey -noout -out $TMP_CERT-key.pem
openssl req -new -key $TMP_CERT-key.pem -config assets/rca-org1-cert.cnf -out $TMP_CERT.csr \
      -subj "/C=DE/ST=NRW/L=Paderborn/O=UC4/OU=UC4/CN=tls-ca"
openssl x509 -req -days 730 -in $TMP_CERT.csr -signkey $TMP_CERT-key.pem -out $TMP_CERT-cert.pem \
      -extensions v3_req -extfile assets/rca-org1-cert.cnf

small_sep

echo "Provide certificate and privkey as kubernetes secret"
kubectl create secret generic key.rca-org1 -n hlf --from-file=key.pem=$TMP_CERT-key.pem
kubectl create secret generic cert.rca-org1 -n hlf --from-file=cert.pem=$TMP_CERT-cert.pem

sep

echo "Generate Org2 root certificate and private key"
TMP_CERT=$(mktemp)
openssl ecparam -name prime256v1 -genkey -noout -out $TMP_CERT-key.pem
openssl req -new -key $TMP_CERT-key.pem -config assets/rca-org2-cert.cnf -out $TMP_CERT.csr \
      -subj "/C=DE/ST=NRW/L=Paderborn/O=UC4/OU=UC4/CN=tls-ca"
openssl x509 -req -days 730 -in $TMP_CERT.csr -signkey $TMP_CERT-key.pem -out $TMP_CERT-cert.pem \
      -extensions v3_req -extfile assets/rca-org2-cert.cnf

small_sep

echo "Provide certificate and privkey as kubernetes secret"
kubectl create secret generic key.rca-org2 -n hlf --from-file=key.pem=$TMP_CERT-key.pem
kubectl create secret generic cert.rca-org2 -n hlf --from-file=cert.pem=$TMP_CERT-cert.pem
