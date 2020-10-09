#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "TLS CA"

echo "Generate TLS CA root certificate and private key"
openssl ecparam -name prime256v1 -genkey -noout -out ca-key.pem
openssl req -new -x509 -key ca-key.pem -out ca-cert.pem -days 730 \
      -subj "/C=DE/ST=Paderborn/L=Paderborn/O=UC4/OU=UC4/CN=uc4.cs.uni-paderborn.de" \
      -addext keyUsage=keyCertSign

echo "Provide certificate and privkey as kubernetes secret"
kubectl create secret generic tls-ca-server-ca-key -n hlf --from-file=./ca-key.pem
kubectl create secret generic tls-ca-server-ca-cert -n hlf --from-file=./ca-cert.pem

rm ca-key.pem ca-cert.pem


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
