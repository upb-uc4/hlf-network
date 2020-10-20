#!/bin/bash

[[ -e scripts/util.sh ]] || { echo >&2 "Please cd into repositories main directory before running this script."; exit 1; }

source ./scripts/util.sh


print_usage() {
  printf "Usage: ./restart -d\n"
  printf "Use -d to reset all clusters\n"
}


while getopts 'd' flag; do
  case "${flag}" in
    d) printf "🐼 Delete all clusters and files\n"
       set +e
       kind delete clusters --all
       sudo rm -rf /data/development
       sudo rm -rf /data/development-2
       printf "🥳 Done!\n"
       exit 1 ;;
    ?) print_usage
       exit 1 ;;
  esac
done


function createCluster() {
  set +e
  sudo rm -rf $1
  set -e

  kind create cluster \
    --config $2 \
    --name "cluster-$3" \
    --kubeconfig $(mktemp) \
    >>log.txt 2>&1
  echo "Successfully created cluster $3" >> log.txt
}

function createCluster1() {
  createCluster /data/development assets/kind.yaml 1
}

function createCluster2() {
  createCluster /data/development-2 assets/kind-2.yaml 2
}

# Prompt password
header "🤖 Fast restart script (for development only)"
sudo printf ""

CURRENT_CONTEXT=$(kubectl config current-context)

# Check if cluster 1 or cluster 2 is currently used, defaults to 1
if [[ "$CURRENT_CONTEXT" == *"2" ]]
then
  CURRENT=2
  NEXT=1
  NEXT_PATH=/data/development
else
  CURRENT=1
  NEXT=2
  NEXT_PATH=/data/development-2
fi

CLUSTERS=$(kind get clusters)
printf "🐨 Creating missing clusters\n"
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

sudo mkdir -p /data/development/hyperledger
sudo chmod -R 777 /data/development
sudo mkdir -p /data/development-2/hyperledger
sudo chmod -R 777 /data/development-2

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

header "Deploy network on cluster $NEXT"
kind export kubeconfig --name "cluster-$NEXT"
./deploy.sh -c $NEXT_PATH/hyperledger
printf "🥳 Done!\n"
