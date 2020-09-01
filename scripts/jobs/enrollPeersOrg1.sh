set -e

echo "Enroll Peer1 at Org1-CA"

export CA_ORG1_HOST=rca-org1.hlf-production-network:7054
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org1/peer1
export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
# We need to copy the certificate of Org1-CA into our tmp directory
mkdir -p $FABRIC_CA_CLIENT_HOME/assets/ca
cp /tmp/hyperledger/org1/ca/crypto/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES

fabric-ca-client enroll -u https://peer1-org1:peer1PW@$CA_ORG1_HOST

