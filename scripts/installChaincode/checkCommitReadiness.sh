peer lifecycle chaincode checkcommitreadiness \
    --channelID mychannel \
    --name uc4-cc \
    --version 1.0 \
    --sequence 1 \
    --tls \
    --cafile /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-tls-ca-hlf-7052.pem \
    --output json \
    --collections-config /tmp/hyperledger/chaincode/collections_config.json
