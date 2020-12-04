#!/bin/bash

kubectl create -f k8s/tls-ca-storage.yaml
kubectl create -f k8s/org0/rca-org0-storage.yaml
kubectl create -f k8s/org0/orderer-org0-storage.yaml
kubectl create -f k8s/org1/rca-org1-storage.yaml
kubectl create -f k8s/org1/peer1-org1-storage.yaml
kubectl create -f k8s/org2/peer1-org2-storage.yaml
kubectl create -f k8s/org2/peer2-org2-storage.yaml
kubectl create -f k8s/org2/rca-org2-storage.yaml
kubectl create -f k8s/org1/peer2-org1-storage.yaml
