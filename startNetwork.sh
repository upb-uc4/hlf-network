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

mkdir -p $TMP_FOLDER/hyperledger
cp -a ./scripts $TMP_FOLDER/hyperledger/scripts

# Fix for weird permission denied errors from mounts using hostPath:
# https://kubernetes.io/docs/concepts/storage/volumes/#hostpath
#
# The files or directories created on the underlying hosts are only writable by root. You either need to run your
# process as root in a privileged Container or modify the file permissions on the host to be able to write to a
# hostPath volume.
set +e
mkdir -p $TMP_FOLDER/hyperledger/org0/admin/msp
chmod 777 $TMP_FOLDER/hyperledger/org0/admin/msp
mkdir -p $TMP_FOLDER/hyperledger/org1/admin/msp
chmod 777 $TMP_FOLDER/hyperledger/org1/admin/msp
mkdir -p $TMP_FOLDER/hyperledger/org2/admin/msp
chmod 777 $TMP_FOLDER/hyperledger/org2/admin/msp
mkdir -p $TMP_FOLDER/hyperledger/org0/orderer
chmod 777 $TMP_FOLDER/hyperledger/org0/orderer
mkdir -p $TMP_FOLDER/hyperledger/org1/peer1/assets
chmod 777 $TMP_FOLDER/hyperledger/org1/peer1/assets
mkdir -p $TMP_FOLDER/hyperledger/org2/peer1/assets
chmod 777 $TMP_FOLDER/hyperledger/org2/peer1/assets
mkdir -p $TMP_FOLDER/hyperledger/uc4
chmod 777 $TMP_FOLDER/hyperledger/uc4
mkdir -p $TMP_FOLDER/hyperledger/uc4/chaincode
chmod 777 $TMP_FOLDER/hyperledger/uc4/chaincode
set -e

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

# For scala api
rm -rf /tmp/hyperledger/
mkdir -p /tmp/hyperledger/
mkdir -p /tmp/hyperledger/org0
mkdir -p /tmp/hyperledger/org1
mkdir -p /tmp/hyperledger/org2
cp $TMP_FOLDER/ca-cert.pem /tmp/hyperledger/
cp -a $TMP_FOLDER/hyperledger/org0/msp /tmp/hyperledger/org0
cp -a $TMP_FOLDER/hyperledger/org1/msp /tmp/hyperledger/org1
cp -a $TMP_FOLDER/hyperledger/org2/msp /tmp/hyperledger/org2

sep

echo -e "Done. Execute \e[2mminikube dashboard\e[22m to open the dashboard or run \e[2m./deleteNetwork.sh\e[22m to shutdown and delete the network."
