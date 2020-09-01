source ./util.sh

header "Orderer"

# TODO use serets to distribute tls root certificate
cp $TMP_FOLDER/ca-cert.pem $TMP_FOLDER/hyperledger/org0/ca

kubectl create -f $K8S/enroll-orderer-org0.yaml -n hlf-production-network
kubectl wait --for=condition=complete job -l app=enroll-orderer --timeout=120s -n hlf-production-network

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
