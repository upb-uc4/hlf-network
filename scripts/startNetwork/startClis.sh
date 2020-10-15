#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "Starting CLIs"

echo "Starting Org1 CLI"

# Provide admincerts to admin msp
# d=$HL_MOUNT/org1/admin/msp/admincerts/
# mkdir -p "$d" && cp $HL_MOUNT/org1/msp/admincerts/admin-org1-cert.pem "$d"

kubectl create -f k8s/org1/cli-org1.yaml
# Copy channel.tx from orderer to peer1 to create the initial channel

# TODO use shared volume for this
# cp $HL_MOUNT/org0/orderer/channel.tx $HL_MOUNT/org1/peer1/assets/

small_sep

echo "Starting Org2 CLI"

# Provide admincerts to admin msp
# d=$HL_MOUNT/org2/admin/msp/admincerts/
# mkdir -p "$d" && cp $HL_MOUNT/org2/msp/admincerts/admin-org2-cert.pem "$d"

kubectl create -f k8s/org2/cli-org2.yaml
kubectl wait --for=condition=ready pod -l app=cli-org1 --timeout=${CONTAINER_TIMEOUT} -n hlf
kubectl wait --for=condition=ready pod -l app=cli-org2 --timeout=${CONTAINER_TIMEOUT} -n hlf