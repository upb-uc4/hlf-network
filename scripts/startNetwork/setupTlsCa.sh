#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "TLS CA"

# Create deployment for tls root ca
echo "Creating TLS CA deployment"
kubectl create -f k8s/tls-ca/tls-ca.yaml -n hlf-production-network


# Expose service for tls root ca
echo "Creating TLS CA service"
kubectl create -f k8s/tls-ca/tls-ca-service.yaml -n hlf-production-network

# Wait until pod and service are ready
echo "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=ca-tls-root --timeout=${CONTAINER_TIMEOUT} -n hlf-production-network
sleep $SERVER_STARTUP_TIME

kubectl exec -n hlf-production-network $(get_pods "ca-tls-root") -i -- bash /tmp/hyperledger/scripts/startNetwork/registerUsers/registerTLSusers.sh

# TODO share trusted root certificate as secret
cp $HL_MOUNT/tls-ca/crypto/ca-cert.pem $HL_MOUNT/ca-cert.pem
