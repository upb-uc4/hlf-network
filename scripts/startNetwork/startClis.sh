#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "Command Line Interfaces"

msg "Starting Org1 CLI"
kubectl create -f k8s/org1/cli-org1.yaml

msg "Starting Org2 CLI"
kubectl create -f k8s/org2/cli-org2.yaml

msg "Waiting for pods"
kubectl wait --for=condition=ready pod -l app=cli-org1 --timeout=${CONTAINER_TIMEOUT} -n hlf
kubectl wait --for=condition=ready pod -l app=cli-org2 --timeout=${CONTAINER_TIMEOUT} -n hlf
