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

source ./scripts/startNetwork/setupTlsCa.sh
source ./scripts/startNetwork/setupOrdererOrgCa.sh
source ./scripts/startNetwork/setupOrg1Ca.sh
source ./scripts/startNetwork/setupOrg2Ca.sh
source ./scripts/startNetwork/setupPeers.sh
source ./scripts/startNetwork/setupOrderer.sh
source ./scripts/startNetwork/startClis.sh
source ./scripts/startNetwork/setupDind.sh
source ./scripts/startNetwork/setupChannel.sh

# For scala api on kubernetes
mkdir -p $HL_MOUNT/api
cp assets/connection_profile_kubernetes.yaml $HL_MOUNT/api
cp $HL_MOUNT/ca-cert.pem $HL_MOUNT/api/ca-cert.pem
mkdir -p $HL_MOUNT/api/org0/msp
mkdir -p $HL_MOUNT/api/org1/msp
mkdir -p $HL_MOUNT/api/org2/msp
cp -r $HL_MOUNT/org0/msp $HL_MOUNT/api/org0/
cp -r $HL_MOUNT/org1/msp $HL_MOUNT/api/org1/
cp -r $HL_MOUNT/org2/msp $HL_MOUNT/api/org2/

# For scala api locally
set +e
rm -rf /tmp/hyperledger/
mkdir -p /tmp/hyperledger/
mkdir -p /tmp/hyperledger/org0
mkdir -p /tmp/hyperledger/org1
mkdir -p /tmp/hyperledger/org2
cp $HL_MOUNT/ca-cert.pem /tmp/hyperledger/
cp -a $HL_MOUNT/org0/msp /tmp/hyperledger/org0
cp -a $HL_MOUNT/org1/msp /tmp/hyperledger/org1
cp -a $HL_MOUNT/org2/msp /tmp/hyperledger/org2
set -e

sep
echo "Done!"
