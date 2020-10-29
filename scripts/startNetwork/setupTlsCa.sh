#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "TLS CA"

msg "Starting TLS CA"
kubectl create -f k8s/tls-ca.yaml

# Wait until pod and service are ready
msg "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=tls-ca --timeout=${CONTAINER_TIMEOUT} -n hlf
sleep $SERVER_STARTUP_TIME

msg "Registering tls users at the tls ca server"
kubectl exec -n hlf $(get_pods "tls-ca") -i -- bash /tmp/hyperledger/scripts/startNetwork/registerUsers/registerTLSusers.sh
