#!/bin/bash

# Exit on errors
set -e

# Debug commands using -d flag
export DEBUG=""
if [[ $1 == "-d" ]]; then
  echo "Debug mode activated"
  export DEBUG="-d"
fi

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

faketime -m -f -1d /bin/bash -c scripts/startNetwork/generateSecrets.sh
source ./scripts/startNetwork/setupTlsCa.sh
source ./scripts/startNetwork/setupOrdererOrgCa.sh
source ./scripts/startNetwork/setupOrg1Ca.sh
source ./scripts/startNetwork/setupOrg2Ca.sh
source ./scripts/startNetwork/startClis.sh
source ./scripts/startNetwork/setupPeers.sh
source ./scripts/startNetwork/setupOrderer.sh
# Wait to ensure peers and database are communicating as expected
sleep 10
source ./scripts/startNetwork/setupChannel.sh

sep
echo "Done!"
