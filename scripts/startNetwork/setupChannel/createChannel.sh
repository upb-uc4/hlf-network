export CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org1/admin/msp
peer channel create \
    -c mychannel \
    -f /tmp/hyperledger/shared/channel/channel.tx \
    -o orderer-org0:7050 \
    --outputBlock /tmp/hyperledger/shared/channel/mychannel.block \
    --tls \
    --cafile /tmp/secrets/tls-ca/cert.pem