peer chaincode invoke \
  -o orderer-org0:7050 \
  --tls \
  --cafile /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-172-17-0-2-30905.pem \
  -C mychannel \
  -n uc4-cc \
  -c '{"function":"initLedger","Args":[]}'

peer chaincode invoke \
  -o orderer-org0:7050 \
  --tls \
  --cafile /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-172-17-0-2-30905.pem \
  -C mychannel \
  -n uc4-cc \
  -c '{"Args":["addCourse","{ \"courseId\": \"course1\",\"courseName\": \"courseName1\",\"courseType\": \"Lecture\",\"startDate\": \"2020-06-29\",\"endDate\": \"2020-06-29\",\"ects\": 3,\"lecturerId\": \"lecturer1\",\"maxParticipants\": 100,\"currentParticipants\": 0,\"courseLanguage\": \"English\",\"courseDescription\": \"some lecture\" }"]}'

#peer chaincode invoke \
#  -o orderer-org0:7050 \
#  --tls \
#  --cafile /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-172-17-0-2-30905.pem \
#  -C mychannel \
#  -n uc4-cc \
#  -c '{"function":"getAllCourses","Args":[]}'