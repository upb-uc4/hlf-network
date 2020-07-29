export CORE_PEER_ADDRESS=peer1-org2:7051
export CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org2/admin/msp
peer chaincode install -n mycc -v 1.0 -p . -l java

export CORE_PEER_ADDRESS=peer2-org2:7051
export CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org2/admin/msp
peer chaincode install -n mycc -v 1.0 -p . -l java