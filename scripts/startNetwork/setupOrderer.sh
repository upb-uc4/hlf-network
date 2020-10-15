#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "Orderer"


# Run kubernetes job to enroll orderer
kubectl create -f k8s/org0/enroll-orderer-org0.yaml
kubectl wait --for=condition=complete job -l app=enroll-orderer --timeout=${CONTAINER_TIMEOUT} -n hlf

# Create configmap to serve configtx to job
kubectl create configmap configtx --from-file=assets/configtx.yaml -n hlf

sep

echo "Starting Orderer"
kubectl create -f k8s/org0/orderer-org0.yaml
kubectl wait --for=condition=ready pod -l app=orderer-org0 --timeout=${CONTAINER_TIMEOUT} -n hlf
