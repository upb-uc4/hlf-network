#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh


header "Starting Peers"

echo "org1-peer1"
kubectl create -f k8s/org1/peer1-org1.yaml
small_sep

echo "org1-peer2"
kubectl create -f k8s/org1/peer2-org1.yaml
small_sep

echo "org2-peer1"
kubectl create -f k8s/org2/peer1-org2.yaml
small_sep

echo "org2-peer2"
kubectl create -f k8s/org2/peer2-org2.yaml
small_sep

echo "Wait until pods of all peers are ready"
kubectl wait --for=condition=ready pod -l app=peer1-org1 --timeout=${CONTAINER_TIMEOUT} -n hlf
kubectl wait --for=condition=ready pod -l app=peer2-org1 --timeout=${CONTAINER_TIMEOUT} -n hlf
kubectl wait --for=condition=ready pod -l app=peer1-org2 --timeout=${CONTAINER_TIMEOUT} -n hlf
kubectl wait --for=condition=ready pod -l app=peer1-org2 --timeout=${CONTAINER_TIMEOUT} -n hlf
