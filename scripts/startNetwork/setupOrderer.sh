#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "Orderer"

msg "Creating configmap for creation of genesis block"
kubectl create configmap configtx --from-file=assets/configtx.yaml -n hlf

msg "Starting orderer"
kubectl create -f k8s/org0/orderer-org0.yaml

msg "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=orderer-org0 --timeout=${CONTAINER_TIMEOUT} -n hlf
