#!/bin/bash

export CORE_PEER_ADDRESS=peer1-org2:7051
export CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org2/admin/msp

export CHAINCODE_ID="$(peer lifecycle chaincode queryinstalled | sed -n '1!p' | sed 's/.*Package ID: \(.*\), Label.*/\1/')"

export CHAINCODE_VERSION=$(head -1 /tmp/hyperledger/chaincode/assets/testversion.txt | tr -d '\r' | tr -d '\n')
echo "CHAINCODE VERSION:: $CHAINCODE_VERSION"

peer lifecycle chaincode approveformyorg \
  -o orderer-org0:7050 \
  --channelID mychannel \
  --name uc4-cc \
  --version "$CHAINCODE_VERSION" --package-id "$CHAINCODE_ID" \
  --sequence 1 \
  --tls \
  --cafile /tmp/secrets/tls-ca/cert.pem \
  --collections-config /tmp/hyperledger/chaincode/assets/collections_config.json
