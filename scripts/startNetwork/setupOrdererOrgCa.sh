#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "Orderer Org CA"

# TODO use serets to distribute tls root certificate
mkdir -p $HL_MOUNT/org0/ca
cp $HL_MOUNT/ca-cert.pem $HL_MOUNT/org0/ca

# Create deployment for orderer org ca
if (($(kubectl get deployment -l app=rca-org0-root --ignore-not-found -n hlf-production-network | wc -l) < 2)); then
  echo "Creating Orderer Org CA deployment"
  kubectl create -f k8s/orderer-org-ca/orderer-org-ca.yaml -n hlf-production-network
else
  echo "Orderer Org CA deployment already exists"
fi

# Expose service for orderer org ca
if (($(kubectl get service -l app=rca-org0-root --ignore-not-found -n hlf-production-network | wc -l) < 2)); then
  echo "Creating Orderer Org CA service"
  kubectl create -f k8s/orderer-org-ca/orderer-org-ca-service.yaml -n hlf-production-network
else
  echo "Orderer Org CA service already exists"
fi

# Wait until pod is ready
echo "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=rca-org0-root --timeout=${CONTAINER_TIMEOUT} -n hlf-production-network
sleep $SERVER_STARTUP_TIME

kubectl exec -n hlf-production-network $(get_pods "rca-org0-root") -i -- bash /tmp/hyperledger/scripts/startNetwork/registerUsers/registerOrdererOrgUsers.sh

