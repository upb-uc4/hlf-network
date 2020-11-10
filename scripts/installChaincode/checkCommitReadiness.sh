peer lifecycle chaincode checkcommitreadiness \
    --channelID mychannel \
    --name uc4-cc \
    --version 1.0 \
    --sequence 1 \
    --tls \
    --cafile /tmp/secrets/tls-ca/cert.pem \
    --output json \
    --collections-config /tmp/hyperledger/chaincode/hlf-chaincode/UC4-chaincode/assets/collections_config.json
