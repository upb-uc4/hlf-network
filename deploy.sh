#!/bin/bash

# read parameter
if [ -z "$1" ]
then
  # BRANCH_TAG default branch = develop
  echo "Installing latest chaincode from develop."
  echo "Use './installChaincode.sh [branch|tag]' to specify another branch or tag."
  export BRANCH_TAG=develop
else
  # BRANCH_TAG read from parameter
  export BRANCH_TAG=$1
fi

set -e
sed -e 's/:[^:\/\/]/="/g;s/$/"/g;s/ *=/=/g' default-config.yaml > env.sh

echo "######################################################"
echo "#   Clone chaincode with branch / tag: $BRANCH_TAG   #"
echo "######################################################"

./scripts/setMountFolder.sh
./startNetwork.sh
./installChaincode.sh $BRANCH_TAG