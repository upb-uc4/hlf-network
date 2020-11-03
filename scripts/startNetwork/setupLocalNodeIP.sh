#!/bin/bash

[[ -e scripts/util.sh ]] || { echo >&2 "Please cd into repositories main directory before running this script."; exit 1; }

source ./scripts/util.sh

# For local testing only!

# Get internal of current worker node
export UC4_KIND_NODE_IP=$(get_worker_ip)
printf "export UC4_KIND_NODE_IP=%s\n" "$UC4_KIND_NODE_IP"

envsubst '${UC4_KIND_NODE_IP}' < assets/connection_profile_kubernetes_template.yaml > assets/connection_profile_kubernetes_local.yaml
