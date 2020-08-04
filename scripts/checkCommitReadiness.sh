peer lifecycle chaincode checkcommitreadiness \
    --channelID mychannel \
    --name uc4-cc \
    --version 1.0 \
    --sequence 1 \
    --tls \
    --cafile /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-172-17-0-2-30905.pem \
    --output json \
    --init-required
