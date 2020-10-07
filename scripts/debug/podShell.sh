#!/bin/bash

source ./scripts/util.sh

if [ -z "$1" ]
then
  echo "Usage: ./scripts/podShell.sh deployment-name [container name]"
else
  if [ -z "$2" ]
  then
    kubectl exec -n hlf-production-network $(get_pods "$1")  -it -- sh
  else
    kubectl exec -n hlf-production-network $(get_pods "$1")  -c $2 -it -- sh
  fi
fi
