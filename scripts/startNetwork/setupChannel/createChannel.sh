export CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org1/admin/msp
peer channel create \
    -c mychannel \
    -f /tmp/hyperledger/org1/peer1/assets/channel.tx \
    -o orderer-org0:7050 \
    --outputBlock /tmp/hyperledger/org1/peer1/assets/mychannel.block \
    --tls \
    --cafile /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-tls-ca-hlf-7052.pem