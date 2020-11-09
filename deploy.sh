#!/bin/bash

# Ensure PWD is correct http://mywiki.wooledge.org/BashFAQ/028
[[ -e scripts/util.sh ]] || { echo >&2 "Please cd into repositories main directory before running this script."; exit 1; }

source ./scripts/util.sh

BRANCH_TAG="feature/publish_to_maven"
CLUSTER_MOUNT="/data/development/hyperledger"
TEST_MODE=""

print_usage() {
  printf "Usage: ./deploy -v -b [branch or tag] -c [custom config file]\n"
  printf "Use -b to specify a branch or tag (default develop)\n"
  printf "Use -t to activate test mode (do not use in production)\n"
  printf "Use -c to specify a cluster mount path (default %s)\n" "$CLUSTER_MOUNT"
}


while getopts 'vtb:c:' flag; do
  case "${flag}" in
    b) BRANCH_TAG="${OPTARG}"
       printf 'Using branch or tag "%s"\n' "$BRANCH_TAG" ;;
    c) CLUSTER_MOUNT="${OPTARG}"
       printf 'Using hyperledger mount path "%s"\n' "$CLUSTER_MOUNT";;
    t) TEST_MODE="-t"
       printf 'Using test mode'
       printf 'Do not use this mode in production!' ;;
    ?) print_usage
       exit 1 ;;
  esac
done

set -e
#TODO Remove old CLUSTER_MOUNT value
sed -i '/.$/a\' scripts/env.sh                                          # Newline at end of file
sed -i "/\bHL_MOUNT\b/d" scripts/env.sh                            # Remove line with CLUSTER_MOUNT
printf 'export HL_MOUNT="%s"' "$CLUSTER_MOUNT" >> scripts/env.sh   # Add CLUSTER_MOUNT environment variable


# Start network and deploy chaincode

./scripts/startNetwork.sh $TEST_MODE

echo -e "\n\n"

if test -z "$BRANCH_TAG"
then
  ./scripts/installChaincode.sh
else
  ./scripts/installChaincode.sh -b $BRANCH_TAG
fi

if [[ $TEST_MODE == "-t" ]]; then
  export UC4_KIND_NODE_IP=$(get_worker_ip)
  printf "Use the following command to set the node ip:\n"
  printf "export UC4_KIND_NODE_IP=%s\n" $UC4_KIND_NODE_IP
fi
