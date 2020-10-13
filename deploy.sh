#!/bin/bash

# Ensure PWD is correct http://mywiki.wooledge.org/BashFAQ/028
[[ -e scripts/util.sh ]] || { echo >&2 "Please cd into repositories main directory before running this script."; exit 1; }

BRANCH_TAG="develop"
CLUSTER_MOUNT="/data/development/hyperledger/"
VERBOSE=""

print_usage() {
  printf "Usage: ./deploy -v -b [branch or tag] -c [custom config file]\n"
  printf "Use -v for verbose output and -b to specify a branch or tag (default develop)\n"
  printf "Use -c to specify a cluster mount path (default %s)\n" "$CLUSTER_MOUNT"
}


while getopts 'vb:c:' flag; do
  case "${flag}" in
    b) BRANCH_TAG="${OPTARG}"
       printf 'Using branch or tag "%s"\n' "$BRANCH_TAG" ;;
    v) VERBOSE="-d"
       printf 'Using verbose mode\n' ;;
    c) CLUSTER_MOUNT="${OPTARG}"
       printf 'Using hyperledger mount path "%s"\n' "$CLUSTER_MOUNT";;
    ?) print_usage
       exit 1 ;;
  esac
done

set -e
# Remove old CLUSTER_MOUNT value
sed -i '/.$/a\' scripts/env.sh                                          # Newline at end of file
sed -i "/\bHL_MOUNT\b/d" scripts/env.sh                            # Remove line with CLUSTER_MOUNT
printf 'export HL_MOUNT="%s"' "$CLUSTER_MOUNT" >> scripts/env.sh   # Add CLUSTER_MOUNT environment variable


# Start network and deploy chaincode

./scripts/startNetwork.sh $VERBOSE

if test -z "$BRANCH_TAG"
then
  ./scripts/installChaincode.sh
else
  ./scripts/installChaincode.sh -b $BRANCH_TAG
fi