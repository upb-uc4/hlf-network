#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "Peers"

msg "Starting org1-peer1"
kubectl create -f k8s/org1/peer1-org1.yaml

msg "Starting org1-peer2"
kubectl create -f k8s/org1/peer2-org1.yaml

msg "Starting org2-peer1"
kubectl create -f k8s/org2/peer1-org2.yaml

msg "Starting org2-peer2"
kubectl create -f k8s/org2/peer2-org2.yaml

msg "Waiting for pods"
(
kubectl wait --for=condition=ready pod -l app=peer1-org1 --timeout=${CONTAINER_TIMEOUT} -n hlf
kubectl wait --for=condition=ready pod -l app=peer2-org1 --timeout=${CONTAINER_TIMEOUT} -n hlf
kubectl wait --for=condition=ready pod -l app=peer1-org2 --timeout=${CONTAINER_TIMEOUT} -n hlf
kubectl wait --for=condition=ready pod -l app=peer2-org2 --timeout=${CONTAINER_TIMEOUT} -n hlf
) || (
sleep 2
kubectl wait --for=condition=ready pod -l app=peer1-org1 --timeout=${CONTAINER_TIMEOUT} -n hlf
kubectl wait --for=condition=ready pod -l app=peer2-org1 --timeout=${CONTAINER_TIMEOUT} -n hlf
kubectl wait --for=condition=ready pod -l app=peer1-org2 --timeout=${CONTAINER_TIMEOUT} -n hlf
kubectl wait --for=condition=ready pod -l app=peer2-org2 --timeout=${CONTAINER_TIMEOUT} -n hlf
)
) || (
sleep 10
kubectl wait --for=condition=ready pod -l app=peer1-org1 --timeout=${CONTAINER_TIMEOUT} -n hlf
kubectl wait --for=condition=ready pod -l app=peer2-org1 --timeout=${CONTAINER_TIMEOUT} -n hlf
kubectl wait --for=condition=ready pod -l app=peer1-org2 --timeout=${CONTAINER_TIMEOUT} -n hlf
kubectl wait --for=condition=ready pod -l app=peer2-org2 --timeout=${CONTAINER_TIMEOUT} -n hlf
)
