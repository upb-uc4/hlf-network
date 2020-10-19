export CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org1/admin/msp
export CORE_PEER_ADDRESS=peer1-org1:7051
peer channel join -b /tmp/hyperledger/shared/channel/mychannel.block

export CORE_PEER_ADDRESS=peer2-org1:7051
peer channel join -b /tmp/hyperledger/shared/channel/mychannel.block


