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
source ./env.sh
source ./util.sh

# Provide scripts via mount
mkdir -p $HL_MOUNT
cp -r ./scripts $HL_MOUNT

source ./scripts/fixPrepareHostPath.sh

small_sep
kubectl create -f $K8S/namespace.yaml

source ./scripts/setupTlsCa.sh
source ./scripts/setupOrdererOrgCa.sh
source ./scripts/setupOrg1Ca.sh
source ./scripts/setupOrg2Ca.sh
source ./scripts/enrollPeers.sh
source ./scripts/startPeers.sh
source ./scripts/setupOrderer.sh
source ./scripts/startClis.sh
source ./scripts/setupDind.sh
source ./scripts/setupChannel.sh

# For scala api on kubernetes
mkdir -p $HL_MOUNT/api
cp connection_profile_kubernetes.yaml $HL_MOUNT/api
cp $HL_MOUNT/ca-cert.pem $HL_MOUNT/api/ca-cert.pem
mkdir -p $HL_MOUNT/api/org0/msp
mkdir -p $HL_MOUNT/api/org1/msp
mkdir -p $HL_MOUNT/api/org2/msp
cp -r $HL_MOUNT/org0/msp $HL_MOUNT/api/org0/
cp -r $HL_MOUNT/org1/msp $HL_MOUNT/api/org1/
cp -r $HL_MOUNT/org2/msp $HL_MOUNT/api/org2/

set +e
# For scala api locally
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
