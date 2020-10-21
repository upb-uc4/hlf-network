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


####################################################################################################
# Variables
####################################################################################################

NEXT=1
LAST=2
NEXT_PATH=/data/development


####################################################################################################
# Functions
####################################################################################################

function createCluster() {
  set +e
  sudo rm -rf $1
  set -e

  if [[ "$4" == "quiet" ]]
  then
    kind create cluster \
      --config $2 \
      --name "cluster-$3" \
      --kubeconfig $(mktemp)\
      >>log.txt 2>&1
    echo "Successfully created cluster $3" >> log.txt
  else
    kind create cluster \
      --config $2 \
      --name "cluster-$3" \
      --kubeconfig $(mktemp)
  fi
}

function createCluster1() {
  createCluster /data/development assets/kind.yaml 1 $1
}

function createCluster2() {
  createCluster /data/development-2 assets/kind-2.yaml 2 $1
}

function createNextCluster() {
  if [[ "$1" == "again" ]]
  then
    echo "😰 No speedup, need to create next cluster..."
  fi

  set +e
  kind delete clusters cluster-$NEXT
  set -e

  if [[ "$NEXT" == "1" ]]
  then
    createCluster1
  else
    createCluster2
  fi
}

function restartOldClusterInBackground() {
  echo "🤯 Restart old cluster in background..."
  kind delete clusters cluster-$LAST>>log.txt 2>&1
  if [[ "$LAST" == "1" ]]
  then
    createCluster1 quiet
  else
    createCluster2 quiet
  fi
  printf  "\n--------------------------------------------------------------------------------\n😎 Backup cluster is ready!\n👉 You can now fast restart the cluster!\n--------------------------------------------------------------------------------\n"
}


####################################################################################################
# Main script
####################################################################################################

# Prompt password
header "🤖 Fast restart script (for development only)"
sudo printf ""

rm log.txt

LAST_CONTEXT=$(kubectl config current-context)

# Check if cluster 1 was last used
if [[ "$LAST_CONTEXT" == *"1" ]]
then
  LAST=1
  NEXT=2
  NEXT_PATH=/data/development-2
fi

restartOldClusterInBackground &
# For better ux
sleep 1

# Ensure next cluster exists
CLUSTERS=$(kind get clusters)
printf "🐨 Ensure next cluster is available\n"
small_sep
if [[ "$CLUSTERS" != *"cluster-$NEXT"* ]]
then
  echo "😀 Create initial cluster..."
  createNextCluster
fi

(
  kind export kubeconfig --name "cluster-$NEXT" &&\
  kubectl wait --for=condition=Ready node --all --timeout 30s
) || (
  # Try again
  echo "😱 Cluster not working" &&\
  echo "🙄 Restart cluster..." &&\
  createNextCluster again &&\
  kind export kubeconfig --name "cluster-$NEXT"
) || exit 1

sudo mkdir -p $NEXT_PATH/hyperledger
sudo chmod -R 777 $NEXT_PATH

set -e

small_sep
echo "🦥 Cluster ready!"
echo "😎 Deploy network..."
small_sep
./deploy.sh -c $NEXT_PATH/hyperledger

wait
printf "🥳 Done!\n"
