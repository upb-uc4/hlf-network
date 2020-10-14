#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "Orderer"


# Run kubernetes job to enroll orderer
kubectl create -f k8s/org0/enroll-orderer-org0.yaml
kubectl wait --for=condition=complete job -l app=enroll-orderer --timeout=${CONTAINER_TIMEOUT} -n hlf

# Create configmap to serve configtx to job
kubectl create configmap configtx --from-file=assets/configtx.yaml -n hlf

kubectl create -f k8s/org0/create-genesis-block.yaml
kubectl wait --for=condition=complete job -l app=create-genesis-block --timeout=${CONTAINER_TIMEOUT} -n hlf

# TODO save genensis.block and channel.tx to secret or configmap
# Note: This will not work, unfortunately

sep

echo "Starting Orderer"
kubectl create -f k8s/org0/orderer-org0.yaml
