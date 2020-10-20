#!/bin/bash

[[ -e scripts/util.sh ]] || { echo >&2 "Please cd into repositories main directory before running this script."; exit 1; }

source ./scripts/util.sh

# Prompt password
sudo printf ""
header "Fast restart script (for development only)"

echo "Get current context"
kubectl config current-context
CURRENT_CONTEXT=$(kubectl config current-context)
# Check if cluster 1 or cluster 2 is currently used, defaults to 1
if [[ "$CURRENT_CONTEXT" == *"2" ]]
then
  CURRENT=2
  NEXT=1
  CURRENT_CONFIG_FILE=assets/kind-2.yaml
  NEXT_PATH=/data/development
else
  CURRENT=1
  NEXT=2
  CURRENT_CONFIG_FILE=assets/kind.yaml
  NEXT_PATH=/data/development-2
fi

echo "Creating missing clusters"
kind get clusters
CLUSTERS=$(kind get clusters)
{
  if [[ "$CLUSTERS" != *"cluster-1"* ]]
  then
    echo "Create cluster 1"
    kind create cluster --config assets/kind.yaml --name "cluster-1"
  fi
} &
{
  if [[ "$CLUSTERS" != *"cluster-2"* ]]
  then
    echo "Create cluster 2"
    kind create cluster --config assets/kind-2.yaml --name "cluster-2"
  fi
} &
wait

echo "Clusters created"

echo "Remove old cluster and deploy network"
kind delete clusters cluster-$CURRENT

set -e
{
  set +e
  rm log.txt
  kind create cluster --config assets/kind.yaml --name "cluster-$CURRENT" --kubeconfig $(mktemp) >>log.txt 2>&1
} &
{
  set +e
  sudo rm -rf $NEXT_PATH

  echo "Use cluster $NEXT for deployment"
  kind export kubeconfig --name "cluster-$NEXT"

  set -e
  sudo mkdir -p $NEXT_PATH/hyperledger
  sudo chmod -R 777 $NEXT_PATH

  ./deploy.sh -c $NEXT_PATH/hyperledger
} &
wait

echo "Finished!"
