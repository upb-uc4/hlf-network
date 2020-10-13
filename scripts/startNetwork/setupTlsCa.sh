#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "TLS CA"

echo "Generate TLS CA root certificate and private key"
TMP_CERT=$(mktemp)
openssl ecparam -name prime256v1 -genkey -noout -out $TMP_CERT-key.pem
openssl req -new -key $TMP_CERT-key.pem -config assets/tls-ca-root-cert.cnf -out $TMP_CERT.csr \
      -subj "/C=DE/ST=Paderborn/L=Paderborn/O=UC4/OU=UC4/CN=tls-ca" 
openssl x509 -req -days 730 -in $TMP_CERT.csr -signkey $TMP_CERT-key.pem -out $TMP_CERT-cert.pem \
      -extensions v3_req -extfile assets/tls-ca-root-cert.cnf

small_sep

echo "Provide certificate and privkey as kubernetes secret"
kubectl create secret generic key.tls-ca -n hlf --from-file=key.pem=$TMP_CERT-key.pem
kubectl create secret generic cert.tls-ca -n hlf --from-file=cert.pem=$TMP_CERT-cert.pem

small_sep

echo "Creating TLS CA"
kubectl create -f k8s/tls-ca.yaml

# Wait until pod and service are ready
echo "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=tls-ca --timeout=${CONTAINER_TIMEOUT} -n hlf
sleep $SERVER_STARTUP_TIME

kubectl exec -n hlf $(get_pods "tls-ca") -i -- bash /tmp/hyperledger/scripts/startNetwork/registerUsers/registerTLSusers.sh

# TODO share trusted root certificate as secret
# cp $HL_MOUNT/tls-ca/crypto/ca-cert.pem $HL_MOUNT/ca-cert.pem
# TODO SECRETS
