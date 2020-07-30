export CORE_PEER_ADDRESS=peer1-org2:7051
export CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org2/admin/msp

export CHAINCODE_ID="$(peer lifecycle chaincode queryinstalled | sed -n '1!p' | sed 's/.*Package ID: \(.*\), Label.*/\1/')"

peer lifecycle chaincode approveformyorg -o orderer-org0:7050 --channelID mychannel --name uc4-cc --version 1.0 --package-id "$CHAINCODE_ID" --sequence 1 --tls --cafile /tmp/hyperledger/org2/peer1/tls-msp/tlscacerts/${PEERS_TLSCACERTS}
