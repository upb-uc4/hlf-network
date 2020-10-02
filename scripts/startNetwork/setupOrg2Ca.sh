#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "Org2 CA"

# TODO share trusted root certificate as secret
mkdir -p $HL_MOUNT/org2/ca/
cp $HL_MOUNT/ca-cert.pem $HL_MOUNT/org2/ca/

# Create deployment for org2 ca
echo "Creating Org2 CA deployment"
kubectl create -f $K8S/org2-ca/org2-ca.yaml -n hlf-production-network

# Expose service for org2 ca
echo "Creating Org2 CA service"
kubectl create -f $K8S/org2-ca/org2-ca-service.yaml -n hlf-production-network

small_sep

# Wait until pod is ready
echo "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=rca-org2-root --timeout=${CONTAINER_TIMEOUT} -n hlf-production-network
sleep $SERVER_STARTUP_TIME
export ORG2_CA_NAME=$(get_pods "rca-org2-root")
echo "Using pod $ORG2_CA_NAME"
small_sep

kubectl exec -n hlf-production-network $(get_pods "rca-org2-root") -i -- bash /tmp/hyperledger/scripts/startNetwork/registerUsers/registerOrg2CaUsers.sh