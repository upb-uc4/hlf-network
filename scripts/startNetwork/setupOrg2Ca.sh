#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "Org2 CA"

msg "Starting Org2 CA"
kubectl create -f k8s/org2/rca-org2.yaml

msg "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=rca-org2 --timeout=${CONTAINER_TIMEOUT} -n hlf
