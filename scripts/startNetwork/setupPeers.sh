#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh


header "Enroll peers"

# TODO use secrete for distribution of root certificate

# Run kubernetes jobs to enroll peers
kubectl create -f k8s/org1/enroll-peers-org1.yaml -n hlf-production-network
kubectl create -f k8s/org2/enroll-peers-org2.yaml -n hlf-production-network
kubectl wait --for=condition=complete job -l app=enroll-peers --timeout=${CONTAINER_TIMEOUT} -n hlf-production-network

header "Starting Peers"

echo "org1-peer1"
kubectl create -f k8s/org1/peer1-org1.yaml -n hlf-production-network
kubectl wait --for=condition=ready pod -l app=peer1-org1 --timeout=${CONTAINER_TIMEOUT} -n hlf-production-network

sep

echo "org1-peer2"
kubectl create -f k8s/org1/peer2-org1.yaml -n hlf-production-network
kubectl wait --for=condition=ready pod -l app=peer2-org1 --timeout=${CONTAINER_TIMEOUT} -n hlf-production-network

sep

echo "org2-peer1"
kubectl create -f k8s/org2/peer1-org2.yaml -n hlf-production-network
kubectl wait --for=condition=ready pod -l app=peer1-org2 --timeout=${CONTAINER_TIMEOUT} -n hlf-production-network

sep

echo "org2-peer2"
kubectl create -f k8s/org2/peer2-org2.yaml -n hlf-production-network
kubectl wait --for=condition=ready pod -l app=peer2-org2 --timeout=${CONTAINER_TIMEOUT} -n hlf-production-network