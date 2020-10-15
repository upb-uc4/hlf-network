#!/bin/bash



# Setup Orderer MSP
# Create MSP directory for org0
HL_MOUNT=/tmp/hyperledger
export MSP_DIR=$HL_MOUNT/org0/msp
mkdir -p $MSP_DIR
mkdir -p $MSP_DIR/admincerts
mkdir -p $MSP_DIR/cacerts
mkdir -p $MSP_DIR/tlscacerts
mkdir -p $MSP_DIR/users
cp /tmp/hyperledger/org0/admin/msp/signcerts/cert.pem $MSP_DIR/admincerts/admin-org0-cert.pem
cp /tmp/hyperledger/org0/ca/crypto/ca-cert.pem $MSP_DIR/cacerts/org0-ca-cert.pem
cp /tmp/secrets/tls-ca/cert.pem $MSP_DIR/tlscacerts/cert.pem

# Create MSP directory for org1
export MSP_DIR=$HL_MOUNT/org1/msp
mkdir -p $MSP_DIR
mkdir -p $MSP_DIR/admincerts
mkdir -p $MSP_DIR/cacerts
mkdir -p $MSP_DIR/tlscacerts
mkdir -p $MSP_DIR/users
cp /tmp/hyperledger/org1/admin/msp/signcerts/cert.pem $MSP_DIR/admincerts/admin-org1-cert.pem
cp /tmp/hyperledger/org1/ca/crypto/ca-cert.pem $MSP_DIR/cacerts/org1-ca-cert.pem
cp /tmp/secrets/tls-ca/cert.pem $MSP_DIR/tlscacerts/cert.pem

# Create MSP directory for org2
export MSP_DIR=$HL_MOUNT/org2/msp
mkdir -p $MSP_DIR
mkdir -p $MSP_DIR/admincerts
mkdir -p $MSP_DIR/cacerts
mkdir -p $MSP_DIR/tlscacerts
mkdir -p $MSP_DIR/users
cp /tmp/hyperledger/org2/admin/msp/signcerts/cert.pem $MSP_DIR/admincerts/admin-org2-cert.pem
cp /tmp/hyperledger/org2/ca/crypto/ca-cert.pem $MSP_DIR/cacerts/org2-ca-cert.pem
cp /tmp/secrets/tls-ca/cert.pem $MSP_DIR/tlscacerts/cert.pem

# Create Genesis Block
configtxgen -configPath /tmp/configmaps/ -profile OrgsOrdererGenesis -outputBlock /tmp/hyperledger/org0/orderer/genesis.block -channelID syschannel
configtxgen -configPath /tmp/configmaps/ -profile OrgsChannel -outputCreateChannelTx /tmp/hyperledger/org0/orderer/channel.tx -channelID mychannel

chmod 644 /tmp/hyperledger/org0/orderer/channel.tx 
