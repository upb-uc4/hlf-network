#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "Starting Docker in Docker in Kubernetes"

mkdir -p $HL_MOUNT/dind

kubectl create -f "k8s/dind/dind.yaml" -n hlf-production-network
kubectl create -f "k8s/dind/dind-service.yaml" -n hlf-production-network
kubectl wait --for=condition=ready pod -l app=dind --timeout=${CONTAINER_TIMEOUT} -n hlf-production-network
