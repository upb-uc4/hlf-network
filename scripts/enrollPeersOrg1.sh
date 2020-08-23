sep
echo "Org1 Peer1"
sep

echo "Enroll Peer1 at Org1-CA"
export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org1/peer1
export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
# We need to copy the certificate of Org1-CA into our tmp directory
mkdir -p $FABRIC_CA_CLIENT_HOME/assets/ca
cp $TMP_FOLDER/hyperledger/org1/ca/crypto/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES

./$CA_CLIENT enroll $DEBUG -u https://peer1-org1:peer1PW@$CA_ORG1_HOST

small_sep


echo "Enroll Peer1 at TLS-CA"
export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/tls-ca/tls-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
# We need to copy the certificate of the TLS CA into our tmp directory
mkdir -p $FABRIC_CA_CLIENT_HOME/assets/tls-ca
cp $TMP_FOLDER/hyperledger/tls-ca/admin/tls-ca-cert.pem $FABRIC_CA_CLIENT_HOME/assets/tls-ca/tls-ca-cert.pem

./$CA_CLIENT enroll $DEBUG -u https://peer1-org1:peer1PW@$CA_TLS_HOST --enrollment.profile tls --csr.hosts peer1-org1

mv $TMP_FOLDER/hyperledger/org1/peer1/tls-msp/keystore/*_sk $TMP_FOLDER/hyperledger/org1/peer1/tls-msp/keystore/key.pem



sep
echo "Org1 Peer2"
sep

echo "Enroll Peer2 at Org1-CA"
export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org1/peer2
export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
# We need to copy the certificate of Org1-CA into our tmp directory
mkdir -p $FABRIC_CA_CLIENT_HOME/assets/ca
cp $TMP_FOLDER/hyperledger/org1/ca/crypto/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES

./$CA_CLIENT enroll $DEBUG -u https://peer2-org1:peer2PW@$CA_ORG1_HOST

small_sep


echo "Enroll Peer2 at TLS-CA"
export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/tls-ca/tls-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
# We need to copy the certificate of the TLS CA into our tmp directory
mkdir -p $FABRIC_CA_CLIENT_HOME/assets/tls-ca
cp $TMP_FOLDER/hyperledger/tls-ca/admin/tls-ca-cert.pem $FABRIC_CA_CLIENT_HOME/assets/tls-ca/tls-ca-cert.pem

./$CA_CLIENT enroll $DEBUG -u https://peer2-org1:peer2PW@$CA_TLS_HOST --enrollment.profile tls --csr.hosts peer2-org1

mv $TMP_FOLDER/hyperledger/org1/peer2/tls-msp/keystore/*_sk $TMP_FOLDER/hyperledger/org1/peer2/tls-msp/keystore/key.pem



sep
echo "Org1 Admin"
sep

echo "Enroll org1 admin identity"
# Note that we assume that peer 1 holds the admin identity
export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org1/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=../../org1/peer1/assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
./$CA_CLIENT enroll $DEBUG -u https://admin-org1:org1AdminPW@$CA_ORG1_HOST

small_sep


echo "Distribute admin certificate across peers"
mkdir $TMP_FOLDER/hyperledger/org1/peer1/msp/admincerts
cp $TMP_FOLDER/hyperledger/org1/admin/msp/signcerts/cert.pem $TMP_FOLDER/hyperledger/org1/peer1/msp/admincerts/org1-admin-cert.pem
# usually this would happen out-of-band
mkdir $TMP_FOLDER/hyperledger/org1/peer2/msp/admincerts
cp $TMP_FOLDER/hyperledger/org1/admin/msp/signcerts/cert.pem $TMP_FOLDER/hyperledger/org1/peer2/msp/admincerts/org1-admin-cert.pem