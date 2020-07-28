export CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org1/admin/msp
export CORE_PEER_ADDRESS=peer1-org1:7051
echo $CORE_PEER_ADDRESS
peer channel join -b /tmp/hyperledger/org1/peer1/assets/mychannel.block

