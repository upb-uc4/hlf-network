export CORE_PEER_ADDRESS=peer1-org1:7051
export CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org1/admin/msp
peer lifecycle chaincode install uc4-cc.tar.gz

export CORE_PEER_ADDRESS=peer2-org1:7051
export CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org1/admin/msp
peer lifecycle chaincode install uc4-cc.tar.gz