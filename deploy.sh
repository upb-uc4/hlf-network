#!/bin/bash

# Ensure PWD is correct http://mywiki.wooledge.org/BashFAQ/028
[[ -e scripts/util.sh ]] || { echo >&2 "Please cd into repositories main directory before running this script."; exit 1; }

source ./scripts/util.sh

CHAINCODE_VERSION_PARAM=""
CLUSTER_MOUNT="/data/development/hyperledger"
TEST_MODE=""

print_usage() {
  printf "Usage: ./deploy.sh [-b <version|release>] [-c <custom config file>] [-t]\n"
  printf "Use -b to specify the version|release to use (default is latest)\n"
  printf "Use -t to activate test mode (do not use in production)\n"
  printf "Use -c to specify a cluster mount path (default %s)\n" "$CLUSTER_MOUNT"
}


while getopts 'tb:c:' flag; do
  case "${flag}" in
    b) CHAINCODE_VERSION_PARAM="-b ${OPTARG}"
       printf 'Using version|release "%s"\n' "$CHAINCODE_VERSION_PARAM" ;;
    c) CLUSTER_MOUNT="${OPTARG}"
       printf 'Using hyperledger mount path "%s"\n' "$CLUSTER_MOUNT";;
    t) TEST_MODE="-t"
       printf 'Using test mode\n'
       printf 'Do not use this mode in production!\n' ;;
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

./scripts/installChaincode.sh $CHAINCODE_VERSION_PARAM

if [[ $TEST_MODE == "-t" ]]; then
  UC4_KIND_NODE_IP=$(get_worker_ip)
  sep
  msg "Use the following commands to configure your testing suite:"
  echo "export UC4_KIND_NODE_IP=$UC4_KIND_NODE_IP"
  echo "export UC4_CONNECTION_PROFILE=/tmp/hyperledger/connection_profile_kubernetes_local.yaml"
  echo "export UC4_TESTBASE_TARGET=PRODUCTION_NETWORK"
  small_sep
  msg "For testing directly in intellij, paste this line to your test environment variables:"
  echo "UC4_KIND_NODE_IP=$UC4_KIND_NODE_IP;UC4_CONNECTION_PROFILE=/tmp/hyperledger/connection_profile_kubernetes_local.yaml;UC4_TESTBASE_TARGET=PRODUCTION_NETWORK"
fi
