source ./util.sh

header "Orderer"

# TODO: Change enrollment to a k8s Job

echo "Enroll Orderer at Org0 enrollment ca"
export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org0/orderer
export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/ca/org0-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
# We need to copy the certificate of Org1-CA into our tmp directory
mkdir -p $FABRIC_CA_CLIENT_HOME/assets/ca
cp $TMP_FOLDER/hyperledger/org0/ca/crypto/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES

./$CA_CLIENT enroll $DEBUG -u https://orderer-org0:ordererpw@$CA_ORDERER_HOST

small_sep


echo "Enroll Orderer at TLS Ca"
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/tls-ca/tls-ca-cert.pem
mkdir -p $FABRIC_CA_CLIENT_HOME/assets/tls-ca
cp $TMP_FOLDER/ca-cert.pem $FABRIC_CA_CLIENT_HOME/assets/tls-ca/tls-ca-cert.pem

./$CA_CLIENT enroll $DEBUG -u https://orderer-org0:ordererPW@$CA_TLS_HOST --enrollment.profile tls --csr.hosts orderer-org0

mv $TMP_FOLDER/hyperledger/org0/orderer/tls-msp/keystore/*_sk $TMP_FOLDER/hyperledger/org0/orderer/tls-msp/keystore/key.pem

small_sep


echo "Enroll Org0's Admin"
export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org0/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=../orderer/assets/ca/org0-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
./$CA_CLIENT enroll $DEBUG -u https://admin-org0:org0adminpw@$CA_ORDERER_HOST
mkdir -p $TMP_FOLDER/hyperledger/org0/orderer/msp/admincerts
cp $TMP_FOLDER/hyperledger/org0/admin/msp/signcerts/cert.pem $TMP_FOLDER/hyperledger/org0/orderer/msp/admincerts/orderer-admin-cert.pem

sep

echo "Creating MSP directories"
# Setup Orderer MSP
# Create MSP directory for org0
export MSP_DIR=$TMP_FOLDER/hyperledger/org0/msp
mkdir -p $MSP_DIR
mkdir -p $MSP_DIR/admincerts
mkdir -p $MSP_DIR/cacerts
mkdir -p $MSP_DIR/tlscacerts
mkdir -p $MSP_DIR/users
cp $TMP_FOLDER/hyperledger/org0/admin/msp/signcerts/cert.pem $MSP_DIR/admincerts/admin-org0-cert.pem
cp $TMP_FOLDER/hyperledger/org0/ca/crypto/ca-cert.pem $MSP_DIR/cacerts/org0-ca-cert.pem
cp $TMP_FOLDER/ca-cert.pem $MSP_DIR/tlscacerts/tls-ca-cert.pem

# Create MSP directory for org1
export MSP_DIR=$TMP_FOLDER/hyperledger/org1/msp
mkdir -p $MSP_DIR
mkdir -p $MSP_DIR/admincerts
mkdir -p $MSP_DIR/cacerts
mkdir -p $MSP_DIR/tlscacerts
mkdir -p $MSP_DIR/users
cp $TMP_FOLDER/hyperledger/org1/admin/msp/signcerts/cert.pem $MSP_DIR/admincerts/admin-org1-cert.pem
cp $TMP_FOLDER/hyperledger/org1/ca/crypto/ca-cert.pem $MSP_DIR/cacerts/org1-ca-cert.pem
cp $TMP_FOLDER/ca-cert.pem $MSP_DIR/tlscacerts/tls-ca-cert.pem

# Create MSP directory for org2
export MSP_DIR=$TMP_FOLDER/hyperledger/org2/msp
mkdir -p $MSP_DIR
mkdir -p $MSP_DIR/admincerts
mkdir -p $MSP_DIR/cacerts
mkdir -p $MSP_DIR/tlscacerts
mkdir -p $MSP_DIR/users
cp $TMP_FOLDER/hyperledger/org2/admin/msp/signcerts/cert.pem $MSP_DIR/admincerts/admin-org2-cert.pem
cp $TMP_FOLDER/hyperledger/org2/ca/crypto/ca-cert.pem $MSP_DIR/cacerts/org2-ca-cert.pem
cp $TMP_FOLDER/ca-cert.pem $MSP_DIR/tlscacerts/tls-ca-cert.pem


sep

echo "Generate genesis block"
./configtxgen -profile OrgsOrdererGenesis -outputBlock $TMP_FOLDER/hyperledger/org0/orderer/genesis.block -channelID syschannel
./configtxgen -profile OrgsChannel -outputCreateChannelTx $TMP_FOLDER/hyperledger/org0/orderer/channel.tx -channelID mychannel

sep

echo "Starting Orderer"
kubectl create -f "$K8S/orderer/orderer.yaml" -n hlf-production-network
kubectl create -f "$K8S/orderer/orderer-service.yaml" -n hlf-production-network
