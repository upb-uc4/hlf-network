#!/bin/bash

get_pods() {
  #1 - app name
  kubectl get pods -l app=$1 --field-selector status.phase=Running -n hlf-production-network --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | head -n 1
}

if [ -z "$1" ]
then
  echo "Usage: ./scripts/getLogs.sh deployment-name [containername]"
else
  if [ -z "$2" ]
  then
    kubectl logs $(get_pods "$1") -n hlf-production-network
  else
    kubectl logs $(get_pods "$1") -c $2 -n hlf-production-network
  fi
fi
