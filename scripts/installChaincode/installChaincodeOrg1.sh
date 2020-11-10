export CORE_PEER_ADDRESS=peer1-org1:7051
export CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org1/admin/msp
echo "Installing chaincode"
peer lifecycle chaincode install UC4-chaincode.tar.gz
echo "Query chaincode"
peer lifecycle chaincode queryinstalled
echo "Query done"


export CORE_PEER_ADDRESS=peer2-org1:7051
export CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org1/admin/msp
peer lifecycle chaincode install UC4-chaincode.tar.gz
echo "Query chaincode"
peer lifecycle chaincode queryinstalled
echo "Query done"
