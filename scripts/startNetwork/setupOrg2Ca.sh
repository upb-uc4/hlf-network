#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "Org2 CA"

# TODO share trusted root certificate as secret
mkdir -p $HL_MOUNT/org2/ca/
cp $HL_MOUNT/ca-cert.pem $HL_MOUNT/org2/ca/

# Create deployment for org2 ca
echo "Creating Org2 CA"
kubectl create -f k8s/org2/rca-org2.yaml

small_sep

# Wait until pod is ready
echo "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=rca-org2 --timeout=${CONTAINER_TIMEOUT} -n hlf
sleep $SERVER_STARTUP_TIME

small_sep

kubectl exec -n hlf $(get_pods "rca-org2") -i -- bash /tmp/hyperledger/scripts/startNetwork/registerUsers/registerOrg2CaUsers.sh