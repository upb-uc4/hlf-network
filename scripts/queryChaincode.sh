peer chaincode query \
  -o orderer-org0:7050 \
  --tls \
  --cafile /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-172-17-0-2-30905.pem \
  -n uc4-cc \
  -C mychannel \
  -c '{"Args":["getAllCourses"]}'