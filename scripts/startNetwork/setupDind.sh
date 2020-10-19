#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "Starting Docker in Docker in Kubernetes"

kubectl create -f k8s/dind.yaml
kubectl wait --for=condition=ready pod -l app=dind --timeout=${CONTAINER_TIMEOUT} -n hlf
