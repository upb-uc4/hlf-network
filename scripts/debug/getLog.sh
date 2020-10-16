#!/bin/bash

source ./scripts/util.sh

if [ -z "$1" ]
then
  echo "Usage: ./scripts/getLogs.sh deployment-name [containername]"
else
  if [ -z "$2" ]
  then
    kubectl logs $(get_pods "$1") -n hlf
  else
    kubectl logs $(get_pods "$1") -c $2 -n hlf
  fi
fi
