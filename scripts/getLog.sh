#!/bin/bash

get_pods() {
  #1 - app name
  kubectl get pods -l app=$1 --field-selector status.phase=Running -n hlf-production-network --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | head -n 1
}

if [ -z "$1" ]
then
  echo "Usage: ./getLogs.sh deployment-name"
else
  echo "Log for $1:"
  kubectl logs $(get_pods "$1") -n hlf-production-network
fi