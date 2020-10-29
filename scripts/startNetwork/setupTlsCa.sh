#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "TLS CA"

msg "Starting TLS CA"
kubectl create -f k8s/tls-ca.yaml

msg "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=tls-ca --timeout=${CONTAINER_TIMEOUT} -n hlf
