#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "Org1 CA"

msg "Starting Org1 CA"
kubectl create -f k8s/org1/rca-org1.yaml

msg "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=rca-org1 --timeout=${CONTAINER_TIMEOUT} -n hlf
