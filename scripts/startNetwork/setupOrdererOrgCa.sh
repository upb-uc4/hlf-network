#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "Orderer Org CA"

msg "Starting Org0 RCA"
kubectl create -f k8s/org0/rca-org0.yaml

msg "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=rca-org0 --timeout=${CONTAINER_TIMEOUT} -n hlf
