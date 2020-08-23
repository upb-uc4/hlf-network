# Exit on errors
set -e

setup-orderer() {
  # Enroll orderer

  sep
  echo "Orderer"
  sep

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
  cp $TMP_FOLDER/hyperledger/tls-ca/admin/tls-ca-cert.pem $FABRIC_CA_CLIENT_HOME/assets/tls-ca/tls-ca-cert.pem

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

  setup-orderer-msp

  sep "Generate genesis block"
  ./configtxgen -profile OrgsOrdererGenesis -outputBlock $TMP_FOLDER/hyperledger/org0/orderer/genesis.block -channelID syschannel
  ./configtxgen -profile OrgsChannel -outputCreateChannelTx $TMP_FOLDER/hyperledger/org0/orderer/channel.tx -channelID mychannel

  sep
  echo "Starting Orderer"
  sep

  kubectl create -f "$K8S/orderer/orderer.yaml" -n hlf-production-network
  kubectl create -f "$K8S/orderer/orderer-service.yaml" -n hlf-production-network
}

setup-orderer-msp() {
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
}

start-clis() {
  sep
  echo "Starting ORG1 CLI"
  sep

  kubectl create -f "$K8S/org1-cli.yaml" -n hlf-production-network

  # Provide admincerts to admin msp
  d=$TMP_FOLDER/hyperledger/org1/admin/msp/admincerts/
  mkdir -p "$d" && cp $TMP_FOLDER/hyperledger/org1/msp/admincerts/admin-org1-cert.pem "$d"

  # Copy channel.tx from orderer to peer1 to create the initial channel
  cp $TMP_FOLDER/hyperledger/org0/orderer/channel.tx $TMP_FOLDER/hyperledger/org1/peer1/assets/

  sep
  echo "Starting ORG2 CLI"
  sep

  kubectl create -f "$K8S/org2-cli.yaml" -n hlf-production-network

  # Provide admincerts to admin msp
  d=$TMP_FOLDER/hyperledger/org2/admin/msp/admincerts/
  mkdir -p "$d" && cp $TMP_FOLDER/hyperledger/org2/msp/admincerts/admin-org2-cert.pem "$d"

  kubectl wait --for=condition=ready pod -l app=cli-org1 --timeout=120s -n hlf-production-network
  kubectl wait --for=condition=ready pod -l app=cli-org2 --timeout=120s -n hlf-production-network

}

setup-dind() {
  sep
  echo "Starting Docker in Docker in Kubernetes"
  sep

  mkdir -p $TMP_FOLDER/hyperledger/dind

  kubectl create -f "$K8S/dind/dind.yaml" -n hlf-production-network
  kubectl create -f "$K8S/dind/dind-service.yaml" -n hlf-production-network
}

create-channel() {
  sep
  echo "Creating channel using CLI1 on Org1 Peer1"
  sep

  CLI1=$(get_pods "cli-org1")

  # Use CLI shell to create channel
  source ./settings.sh
  envsubst <scripts/createChannel.sh>$TMP_FOLDER/.createChannel.sh

  kubectl exec -n hlf-production-network $CLI1 -i -- sh < $TMP_FOLDER/.createChannel.sh
  rm $TMP_FOLDER/.createChannel.sh

  # Copy mychannel.block from peer1-org1 to peer1-org2
  cp $TMP_FOLDER/hyperledger/org1/peer1/assets/mychannel.block $TMP_FOLDER/hyperledger/org2/peer1/assets/mychannel.block

  sep
  echo "Joining channel using CLI1 on Org1 Peer1 and Peer2"
  sep

  kubectl exec -n hlf-production-network $CLI1 -i -- sh < scripts/joinChannelOrg1.sh

  sep
  echo "Joining channel using CLI2 on Org2 Peer1"
  sep

  CLI2=$(get_pods "cli-org2")

  kubectl exec -n hlf-production-network $CLI2 -i -- sh < scripts/joinChannelOrg2.sh
}


# Debug commands using -d flag
export DEBUG=""
if [[ $1 == "-d" ]]; then
  echo "Debug mode activated"
  export DEBUG="-d"
fi

# Set environment variables
source ./env.sh
source ./util.sh

# Use configuration file to generate kubernetes setup from the template
# TODO: Avoid necessity for configuring IPs by making use of kubernetes' internal DNS
./applyConfig.sh

mkdir -p $TMP_FOLDER/hyperledger

# Mount tmp folder
# TODO: Replace local mounts with PVCs
small_sep
echo "Mounting tmp folder to minikube"
minikube mount $TMP_FOLDER/hyperledger:/hyperledger &
sleep 3

small_sep
kubectl create -f $K8S/namespace.yaml

source ./scripts/setupTlsCa.sh
source ./scripts/setupOrdererOrgCa.sh
source ./scripts/setupOrg1Ca.sh
source ./scripts/setupOrg2Ca.sh
source ./scripts/enrollPeersOrg1.sh
source ./scripts/enrollPeersOrg2.sh
source ./scripts/startPeers.sh
setup-orderer
start-clis
setup-dind
create-channel


# For scala api
rm -rf /tmp/hyperledger/
mkdir -p /tmp/hyperledger/
mkdir -p /tmp/hyperledger/org0
mkdir -p /tmp/hyperledger/org1
mkdir -p /tmp/hyperledger/org2
cp $TMP_FOLDER/ca-cert.pem /tmp/hyperledger/
cp -a $TMP_FOLDER/hyperledger/org0/msp /tmp/hyperledger/org0
cp -a $TMP_FOLDER/hyperledger/org1/msp /tmp/hyperledger/org1
cp -a $TMP_FOLDER/hyperledger/org2/msp /tmp/hyperledger/org2

sep

echo -e "Done. Execute \e[2mminikube dashboard\e[22m to open the dashboard or run \e[2m./deleteNetwork.sh\e[22m to shutdown and delete the network."
