export CORE_PEER_ADDRESS=peer1-org1:7051
export CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org1/admin/msp

export CHAINCODE_ID="$(peer lifecycle chaincode queryinstalled | sed -n '1!p' | sed 's/.*Package ID: \(.*\), Label.*/\1/')"

peer lifecycle chaincode approveformyorg \
  -o orderer-org0:7050 \
  --channelID mychannel \
  --name uc4-cc \
  --version 1.0 \
  --package-id "$CHAINCODE_ID" \
  --sequence 1 \
  --tls \
  --cafile /tmp/secrets/tls-ca/cert.pem \
  --collections-config /tmp/hyperledger/chaincode/collections_config.json