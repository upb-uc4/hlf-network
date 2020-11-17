#!/bin/bash

export CHAINCODE_VERSION=$(</tmp/hyperledger/chaincode/assets/testversion.txt)

peer lifecycle chaincode checkcommitreadiness \
    --channelID mychannel \
    --name uc4-cc \
    --version "$CHAINCODE_VERSION" \
    --sequence 1 \
    --tls \
    --cafile /tmp/secrets/tls-ca/cert.pem \
    --output json \
    --collections-config /tmp/hyperledger/chaincode/assets/collections_config.json
