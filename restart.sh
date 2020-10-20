#!/bin/bash

[[ -e scripts/util.sh ]] || { echo >&2 "Please cd into repositories main directory before running this script."; exit 1; }

source ./scripts/util.sh

function createCluster() {
  set +e
  sudo rm -rf $1
  set -e

  kind create cluster \
    --config $2 \
    --name "cluster-$3" \
    --kubeconfig $(mktemp) \
    >>log.txt 2>&1
  sudo mkdir -p $1/hyperledger
  sudo chmod -R 777 $1
}

function createCluster1() {
  createCluster /data/development assets/kind.yaml 1
}

function createCluster2() {
  createCluster /data/development-2 assets/kind-2.yaml 2
}

# Prompt password
header "Fast restart script (for development only)"
sudo echo ""

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
CLUSTERS=$(kind get clusters)
{
  if [[ "$CLUSTERS" != *"cluster-1"* ]]
  then
    createCluster1
  fi
} &
{
  if [[ "$CLUSTERS" != *"cluster-2"* ]]
  then
    createCluster2
  fi
} &
wait

echo "Clusters ready!"
echo "Deploy network on current cluster and restart old cluster"

set -e
{
  kind delete clusters cluster-$CURRENT >>log.txt 2>&1
  if [[ "$CURRENT" == "1" ]]
  then
    createCluster1
  else
    createCluster2
  fi
} &
{
  header "Deploy network on cluster $NEXT"
  kind export kubeconfig --name "cluster-$NEXT"
  ./deploy.sh -c $NEXT_PATH/hyperledger
} &
wait
