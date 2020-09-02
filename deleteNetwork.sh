#!/bin/bash

# Set environment variables

source ./env.sh

# Delete namespace and all contained resources
kubectl delete -f $K8S/namespace.yaml

echo Delete temporary directories
rm -rf $TMP_FOLDER
