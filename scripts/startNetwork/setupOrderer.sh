#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "Orderer"


# Run kubernetes job to enroll orderer
kubectl create -f k8s/org0/enroll-orderer-org0.yaml -n hlf-production-network
kubectl wait --for=condition=complete job -l app=enroll-orderer --timeout=${CONTAINER_TIMEOUT} -n hlf-production-network

echo "Creating MSP directories"
# Setup Orderer MSP
# Create MSP directory for org0
export MSP_DIR=$HL_MOUNT/org0/msp
mkdir -p $MSP_DIR
mkdir -p $MSP_DIR/admincerts
mkdir -p $MSP_DIR/cacerts
mkdir -p $MSP_DIR/tlscacerts
mkdir -p $MSP_DIR/users
cp $HL_MOUNT/org0/admin/msp/signcerts/cert.pem $MSP_DIR/admincerts/admin-org0-cert.pem
cp $HL_MOUNT/org0/ca/crypto/ca-cert.pem $MSP_DIR/cacerts/org0-ca-cert.pem
cp $HL_MOUNT/ca-cert.pem $MSP_DIR/tlscacerts/tls-ca-cert.pem

# Create MSP directory for org1
export MSP_DIR=$HL_MOUNT/org1/msp
mkdir -p $MSP_DIR
mkdir -p $MSP_DIR/admincerts
mkdir -p $MSP_DIR/cacerts
mkdir -p $MSP_DIR/tlscacerts
mkdir -p $MSP_DIR/users
cp $HL_MOUNT/org1/admin/msp/signcerts/cert.pem $MSP_DIR/admincerts/admin-org1-cert.pem
cp $HL_MOUNT/org1/ca/crypto/ca-cert.pem $MSP_DIR/cacerts/org1-ca-cert.pem
cp $HL_MOUNT/ca-cert.pem $MSP_DIR/tlscacerts/tls-ca-cert.pem

# Create MSP directory for org2
export MSP_DIR=$HL_MOUNT/org2/msp
mkdir -p $MSP_DIR
mkdir -p $MSP_DIR/admincerts
mkdir -p $MSP_DIR/cacerts
mkdir -p $MSP_DIR/tlscacerts
mkdir -p $MSP_DIR/users
cp $HL_MOUNT/org2/admin/msp/signcerts/cert.pem $MSP_DIR/admincerts/admin-org2-cert.pem
cp $HL_MOUNT/org2/ca/crypto/ca-cert.pem $MSP_DIR/cacerts/org2-ca-cert.pem
cp $HL_MOUNT/ca-cert.pem $MSP_DIR/tlscacerts/tls-ca-cert.pem


sep

echo "Generate genesis block"
./assets/configtxgen -configPath $PWD/assets/ -profile OrgsOrdererGenesis -outputBlock $HL_MOUNT/org0/orderer/genesis.block -channelID syschannel
./assets/configtxgen -configPath $PWD/assets/ -profile OrgsChannel -outputCreateChannelTx $HL_MOUNT/org0/orderer/channel.tx -channelID mychannel

sep

echo "Starting Orderer"
kubectl create -f "k8s/org0/orderer-org0.yaml" -n hlf-production-network
