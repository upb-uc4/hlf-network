#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "Orderer Org CA"

# TODO use serets to distribute tls root certificate
mkdir -p $HL_MOUNT/org0/ca
cp $HL_MOUNT/ca-cert.pem $HL_MOUNT/org0/ca

kubectl create -f k8s/org0/rca-org0.yaml -n hlf-production-network

# Wait until pod is ready
echo "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=rca-org0 --timeout=${CONTAINER_TIMEOUT} -n hlf-production-network
sleep $SERVER_STARTUP_TIME

kubectl exec -n hlf-production-network $(get_pods "rca-org0") -i -- bash /tmp/hyperledger/scripts/startNetwork/registerUsers/registerOrdererOrgUsers.sh

