peer chaincode instantiate -n mycc -v 0 -c '{"Args":["initLedger"]}' -C mychannel -o orderer-org0:7050 --tls --cafile /tmp/hyperledger/org2/peer1/tls-msp/tlscacerts/tls-172-17-0-2-30905.pem
