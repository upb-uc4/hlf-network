#!/bin/bash

source ./scripts/util.sh

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
