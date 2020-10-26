#!/bin/bash

[[ -e scripts/util.sh ]] || { echo >&2 "Please cd into repositories main directory before running this script."; exit 1; }

source ./scripts/util.sh


print_usage() {
  printf "🧙 Usage: ./restart [-d] [-v] [-b <branch or tag>]\n"
  printf "Use -v for verbose output\n"
  printf "Use -b to specify a chaincode branch or tag (default develop)\n"
  printf "Use -d to reset all clusters\n"
}

PARAMS=""

while getopts 'vdb:' flag; do
  case "${flag}" in
    b) BRANCH_TAG="${OPTARG}"
       PARAMS="$PARAMS -b $BRANCH_TAG"
       printf 'Using chaincode branch or tag "%s"\n' "$BRANCH_TAG" ;;
    v) PARAMS="$PARAMS -v"
       printf 'Using verbose mode\n' ;;
    d) printf "🐼 Delete all clusters and files\n"
       set +e
       kind delete clusters cluster-1 cluster-2
       sudo rm -rf /data/development-1
       sudo rm -rf /data/development-2
       printf "🥳 Done!\n"
       exit 1 ;;
    ?) print_usage
       exit 1 ;;
  esac
done

echo $PARAMS

####################################################################################################
# Functions
####################################################################################################

function createCluster() {
  set +e
  sudo rm -rf /data/development-$1
  set -e

  if [[ "$2" == "quiet" ]]
  then
    kind create cluster \
      --config assets/kind-$1.yaml \
      --name "cluster-$1" \
      --kubeconfig $(mktemp)\
      >>log.txt 2>&1
    echo "Successfully created cluster $1" >> log.txt
  else
    kind create cluster \
      --config assets/kind-$1.yaml \
      --name "cluster-$1" \
      --kubeconfig $(mktemp)
  fi
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
    createCluster 1
  else
    createCluster 2
  fi
}

function restartOldClusterInBackground() {
  echo "🤯 Restart old cluster in background..."
  kind delete clusters cluster-$LAST>>log.txt 2>&1

  if [[ "$LAST" == "1" ]]
  then
    createCluster 1 quiet
  else
    createCluster 2 quiet
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

NEXT=1
LAST=2

# Check if cluster 1 was last used
if [[ "$LAST_CONTEXT" == *"1" ]]
then
  LAST=1
  NEXT=2
fi

NEXT_PATH=/data/development-$NEXT

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
./deploy.sh -c $NEXT_PATH/hyperledger $PARAMS

wait
printf "🥳 Done!\n"
