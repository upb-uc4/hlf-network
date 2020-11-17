chaincode_version=cat /tmp/hyperledger/chaincode/assets/testversion.txt
msg "CHAINCODE VERSION: $chaincode_version"

peer lifecycle chaincode commit \
    -o orderer-org0:7050 \
    --channelID mychannel \
    --name uc4-cc \
    --version $chaincode_version \
    --sequence 1 \
    --tls \
    --cafile /tmp/secrets/tls-ca/cert.pem \
    --peerAddresses peer1-org1:7051 \
    --tlsRootCertFiles /tmp/secrets/tls-ca/cert.pem  \
    --peerAddresses peer1-org2:7051 \
    --tlsRootCertFiles /tmp/secrets/tls-ca/cert.pem  \
    --collections-config /tmp/hyperledger/chaincode/assets/collections_config.json
