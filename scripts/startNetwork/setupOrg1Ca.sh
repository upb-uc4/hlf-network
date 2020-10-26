#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "Org1 CA"

echo "Creating Org1 CA"
kubectl create -f k8s/org1/rca-org1.yaml

small_sep

# Wait until pod is ready
echo "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=rca-org1 --timeout=${CONTAINER_TIMEOUT} -n hlf
sleep $SERVER_STARTUP_TIME

small_sep

kubectl exec -n hlf $(get_pods "rca-org1") -i -- bash /tmp/hyperledger/scripts/startNetwork/registerUsers/registerOrg1CaUsers.sh
