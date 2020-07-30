export CORE_PEER_ADDRESS=peer1-org1:7051
export CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org1/admin/msp

export CHAINCODE="$(peer lifecycle chaincode queryinstalled | sed -n '1!p' | sed 's/.*Package ID: \(.*\), Label.*/\1/')"
