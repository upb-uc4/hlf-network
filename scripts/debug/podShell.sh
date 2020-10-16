#!/bin/bash

source ./scripts/util.sh

if [ -z "$1" ]
then
  echo "Usage: ./scripts/podShell.sh deployment-name [container name]"
else
  if [ -z "$2" ]
  then
    kubectl -n hlf exec --stdin --tty $(get_pods "$1") -- bash
  else
    kubectl -n hlf exec --stdin --tty $(get_pods "$1")  -c $2  -- bash
  fi
fi
