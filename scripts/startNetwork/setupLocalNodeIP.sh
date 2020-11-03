#!/bin/bash

[[ -e scripts/util.sh ]] || { echo >&2 "Please cd into repositories main directory before running this script."; exit 1; }

# For local testing only!

# Get internal of current worker node
export NODE_IP=$(kubectl get nodes -l uc4.cs.upb.de/kind-worker -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}')

envsubst '${NODE_IP}' < assets/connection_profile_kubernetes_template.yaml > assets/connection_profile_kubernetes_local.yaml
