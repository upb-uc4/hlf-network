#!/bin/bash

# Exit on errors
set -e

TEST_MODE=""
while getopts 't' flag; do
  case "${flag}" in
    t) TEST_MODE="-t" ;;
    ?) printf 'Invalid flag!' ;;
  esac
done

# Set environment variables
source ./scripts/env.sh
source ./scripts/util.sh

# Provide scripts via mount
echo $HL_MOUNT
mkdir -p $HL_MOUNT
cp -r ./scripts $HL_MOUNT

source ./scripts/startNetwork/fixPrepareHostPath.sh

small_sep
kubectl create -f k8s/namespace.yaml

faketime -m -f -1d /bin/bash -c "scripts/startNetwork/generateSecrets.sh $TEST_MODE"
source ./scripts/startNetwork/setupTlsCa.sh
source ./scripts/startNetwork/setupOrdererOrgCa.sh
source ./scripts/startNetwork/setupOrg1Ca.sh
if [[ $TEST_MODE == "-t" ]]; then
  source ./scripts/startNetwork/registerOrg1TestAdmin.sh
fi
source ./scripts/startNetwork/setupOrg2Ca.sh
source ./scripts/startNetwork/startClis.sh
source ./scripts/startNetwork/setupPeers.sh
source ./scripts/startNetwork/setupOrderer.sh
# Wait to ensure peers and database are communicating as expected
sleep 10
source ./scripts/startNetwork/setupChannel.sh

sep
msg "Done!"
