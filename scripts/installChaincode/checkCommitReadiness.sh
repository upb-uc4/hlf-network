chaincode_version=cat /tmp/hyperledger/chaincode/assets/testversion.txt

peer lifecycle chaincode checkcommitreadiness \
    --channelID mychannel \
    --name uc4-cc \
    --version $chaincode_version \
    --sequence 1 \
    --tls \
    --cafile /tmp/secrets/tls-ca/cert.pem \
    --output json \
    --collections-config /tmp/hyperledger/chaincode/assets/collections_config.json
