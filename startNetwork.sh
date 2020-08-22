# Exit on errors
set -e

setup-org1-ca() {
  sep
  echo "Org1 CA"
  sep

  # Create deployment for org1 ca
  if (($(kubectl get deployment -l app=rca-org1-root --ignore-not-found -n hlf-production-network | wc -l) < 2)); then
    echo "Creating Org1 CA deployment"
    kubectl create -f $K8S/org1-ca/org1-ca.yaml -n hlf-production-network
  else
    echo "Org1 CA deployment already exists"
  fi

  # Expose service for org1 ca
  if (($(kubectl get service -l app=rca-org1-root --ignore-not-found -n hlf-production-network | wc -l) < 2)); then
    echo "Creating Org1 CA service"
    kubectl create -f $K8S/org1-ca/org1-ca-service.yaml -n hlf-production-network
  else
    echo "Org1 CA service already exists"
  fi
  CA_ORG1_HOST=$(minikube service rca-org1 --url -n hlf-production-network | cut -c 8-)
  echo "Org1 CA service exposed on $CA_ORG1_HOST"
  small_sep

  # Wait until pod is ready
  echo "Waiting for pod"
  kubectl wait --for=condition=ready pod -l app=rca-org1-root --timeout=120s -n hlf-production-network
  sleep $SERVER_STARTUP_TIME
  ORG1_CA_NAME=$(get_pods "rca-org1-root")
  echo "Using pod $ORG1_CA_NAME"
  small_sep

  export FABRIC_CA_CLIENT_TLS_CERTFILES=../crypto/ca-cert.pem
  export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org1/ca/admin
  mkdir -p $FABRIC_CA_CLIENT_HOME

  # Query TLS CA server to enroll an admin identity
  echo "Use CA-client to enroll admin"
  small_sep
  ./$CA_CLIENT enroll $DEBUG -u https://rca-org1-admin:rca-org1-adminpw@$CA_ORG1_HOST
  small_sep

  # Query TLS CA server to register other identities
  echo "Use CA-client to register identities"
  small_sep
  # The id.secret password ca be used to enroll the registered users lateron
  ./$CA_CLIENT register $DEBUG --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://$CA_ORG1_HOST
  small_sep
  ./$CA_CLIENT register $DEBUG --id.name peer2-org1 --id.secret peer2PW --id.type peer -u https://$CA_ORG1_HOST
  small_sep
  ./$CA_CLIENT register $DEBUG --id.name admin-org1 --id.secret org1AdminPW --id.type user -u https://$CA_ORG1_HOST
  small_sep
  ./$CA_CLIENT register $DEBUG --id.name scala-admin-org1 --id.secret scalaAdminPW --id.type admin -u https://$CA_ORG1_HOST
  small_sep
  ./$CA_CLIENT register $DEBUG --id.name user-org1 --id.secret org1UserPW --id.type user -u https://$CA_ORG1_HOST
}

setup-org2-ca() {
  sep
  echo "Org2 CA"
  sep

  # Create deployment for org2 ca
  if (($(kubectl get deployment -l app=rca-org2-root --ignore-not-found -n hlf-production-network | wc -l) < 2)); then
    echo "Creating Org2 CA deployment"
    kubectl create -f $K8S/org2-ca/org2-ca.yaml -n hlf-production-network
  else
    echo "Org2 CA deployment already exists"
  fi

  # Expose service for org2 ca
  if (($(kubectl get service -l app=rca-org2-root --ignore-not-found -n hlf-production-network | wc -l) < 2)); then
    echo "Creating Org2 CA service"
    kubectl create -f $K8S/org2-ca/org2-ca-service.yaml -n hlf-production-network
  else
    echo "Org2 CA service already exists"
  fi
  CA_ORG2_HOST=$(minikube service rca-org2 --url -n hlf-production-network | cut -c 8-)
  echo "Org2 CA service exposed on $CA_ORG2_HOST"
  small_sep

  # Wait until pod is ready
  echo "Waiting for pod"
  kubectl wait --for=condition=ready pod -l app=rca-org2-root --timeout=120s -n hlf-production-network
  sleep $SERVER_STARTUP_TIME
  ORG2_CA_NAME=$(get_pods "rca-org2-root")
  echo "Using pod $ORG2_CA_NAME"
  small_sep

  export FABRIC_CA_CLIENT_TLS_CERTFILES=../crypto/ca-cert.pem
  export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org2/ca/admin
  mkdir -p $FABRIC_CA_CLIENT_HOME

  # Query TLS CA server to enroll an admin identity
  echo "Use CA-client to enroll admin"
  small_sep
  ./$CA_CLIENT enroll $DEBUG -u https://rca-org2-admin:rca-org2-adminpw@$CA_ORG2_HOST
  small_sep

  # Query TLS CA server to register other identities
  echo "Use CA-client to register identities"
  small_sep
  # The id.secret password ca be used to enroll the registered users lateron
  ./$CA_CLIENT register $DEBUG --id.name peer1-org2 --id.secret peer1PW --id.type peer -u https://$CA_ORG2_HOST
  small_sep
  ./$CA_CLIENT register $DEBUG --id.name peer2-org2 --id.secret peer2PW --id.type peer -u https://$CA_ORG2_HOST
  small_sep
  ./$CA_CLIENT register $DEBUG --id.name admin-org2 --id.secret org2AdminPW --id.type user -u https://$CA_ORG2_HOST
  small_sep
  ./$CA_CLIENT register $DEBUG --id.name user-org2 --id.secret org2UserPW --id.type user -u https://$CA_ORG2_HOST
}

enroll-org1-peers() {
  # Enroll peer 1

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

  # We need to copy the certificate of the TLS CA into our tmp directory
  mkdir -p $FABRIC_CA_CLIENT_HOME/assets/tls-ca
  cp $TMP_FOLDER/hyperledger/tls-ca/admin/tls-ca-cert.pem $FABRIC_CA_CLIENT_HOME/assets/tls-ca/tls-ca-cert.pem

  export FABRIC_CA_CLIENT_MSPDIR=tls-msp
  ./$CA_CLIENT enroll $DEBUG -u https://peer1-org1:peer1PW@$CA_TLS_HOST --enrollment.profile tls --csr.hosts peer1-org1

  mv $TMP_FOLDER/hyperledger/org1/peer1/tls-msp/keystore/*_sk $TMP_FOLDER/hyperledger/org1/peer1/tls-msp/keystore/key.pem

  # Enroll peer 2

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

  # We need to copy the certificate of the TLS CA into our tmp directory
  mkdir -p $FABRIC_CA_CLIENT_HOME/assets/tls-ca
  cp $TMP_FOLDER/hyperledger/tls-ca/admin/tls-ca-cert.pem $FABRIC_CA_CLIENT_HOME/assets/tls-ca/tls-ca-cert.pem

  export FABRIC_CA_CLIENT_MSPDIR=tls-msp
  ./$CA_CLIENT enroll $DEBUG -u https://peer2-org1:peer2PW@$CA_TLS_HOST --enrollment.profile tls --csr.hosts peer2-org1

  mv $TMP_FOLDER/hyperledger/org1/peer2/tls-msp/keystore/*_sk $TMP_FOLDER/hyperledger/org1/peer2/tls-msp/keystore/key.pem

  # Enroll Org1 admin

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
}

enroll-org2-peers() {
  # Enroll peer 1

  sep
  echo "Org2 Peer1"
  sep

  echo "Enroll Peer1 at Org2-CA"

  export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org2/peer1
  export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/ca/org2-ca-cert.pem
  export FABRIC_CA_CLIENT_MSPDIR=msp

  # We need to copy the certificate of Org2-CA into our tmp directory
  mkdir -p $FABRIC_CA_CLIENT_HOME/assets/ca
  cp $TMP_FOLDER/hyperledger/org2/ca/crypto/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES

  ./$CA_CLIENT enroll $DEBUG -u https://peer1-org2:peer1PW@$CA_ORG2_HOST

  small_sep

  echo "Enroll Peer1 at TLS-CA"

  export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/tls-ca/tls-ca-cert.pem

  # We need to copy the certificate of the TLS CA into our tmp directory
  mkdir -p $FABRIC_CA_CLIENT_HOME/assets/tls-ca
  cp $TMP_FOLDER/hyperledger/tls-ca/admin/tls-ca-cert.pem $FABRIC_CA_CLIENT_HOME/assets/tls-ca/tls-ca-cert.pem

  export FABRIC_CA_CLIENT_MSPDIR=tls-msp
  ./$CA_CLIENT enroll $DEBUG -u https://peer1-org2:peer1PW@$CA_TLS_HOST --enrollment.profile tls --csr.hosts peer1-org2

  mv $TMP_FOLDER/hyperledger/org2/peer1/tls-msp/keystore/*_sk $TMP_FOLDER/hyperledger/org2/peer1/tls-msp/keystore/key.pem

  # Enroll peer 2

  sep
  echo "Org2 Peer2"
  sep

  echo "Enroll Peer2 at Org2-CA"

  export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org2/peer2
  export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/ca/org2-ca-cert.pem
  export FABRIC_CA_CLIENT_MSPDIR=msp

  # We need to copy the certificate of Org2-CA into our tmp directory
  mkdir -p $FABRIC_CA_CLIENT_HOME/assets/ca
  cp $TMP_FOLDER/hyperledger/org2/ca/crypto/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES

  ./$CA_CLIENT enroll $DEBUG -u https://peer2-org2:peer2PW@$CA_ORG2_HOST

  small_sep

  echo "Enroll Peer2 at TLS-CA"

  export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/tls-ca/tls-ca-cert.pem

  # We need to copy the certificate of the TLS CA into our tmp directory
  mkdir -p $FABRIC_CA_CLIENT_HOME/assets/tls-ca
  cp $TMP_FOLDER/hyperledger/tls-ca/admin/tls-ca-cert.pem $FABRIC_CA_CLIENT_HOME/assets/tls-ca/tls-ca-cert.pem

  export FABRIC_CA_CLIENT_MSPDIR=tls-msp
  ./$CA_CLIENT enroll $DEBUG -u https://peer2-org2:peer2PW@$CA_TLS_HOST --enrollment.profile tls --csr.hosts peer2-org2

  mv $TMP_FOLDER/hyperledger/org2/peer2/tls-msp/keystore/*_sk $TMP_FOLDER/hyperledger/org2/peer2/tls-msp/keystore/key.pem

  # Enroll Org2 admin

  sep
  echo "Org2 Admin"
  sep

  echo "Enroll org2 admin identity"

  # Note that we assume that peer 1 holds the admin identity
  export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org2/admin
  export FABRIC_CA_CLIENT_TLS_CERTFILES=../../org2/peer1/assets/ca/org2-ca-cert.pem
  export FABRIC_CA_CLIENT_MSPDIR=msp
  ./$CA_CLIENT enroll $DEBUG -u https://admin-org2:org2AdminPW@$CA_ORG2_HOST

  small_sep

  echo "Distribute admin certificate across peers"

  mkdir $TMP_FOLDER/hyperledger/org2/peer1/msp/admincerts
  cp $TMP_FOLDER/hyperledger/org2/admin/msp/signcerts/cert.pem $TMP_FOLDER/hyperledger/org2/peer1/msp/admincerts/org2-admin-cert.pem

  # usually this would happen out-of-band
  mkdir $TMP_FOLDER/hyperledger/org2/peer2/msp/admincerts
  cp $TMP_FOLDER/hyperledger/org2/admin/msp/signcerts/cert.pem $TMP_FOLDER/hyperledger/org2/peer2/msp/admincerts/org2-admin-cert.pem
}

start-org1-peer1() {
  sep
  echo "Starting Org1 Peer1"
  sep

  kubectl create -f "$K8S/org1-peer1/org1-peer1.yaml" -n hlf-production-network
  kubectl create -f "$K8S/org1-peer1/org1-peer1-service.yaml" -n hlf-production-network
  kubectl wait --for=condition=ready pod -l app=peer1-org1 --timeout=120s -n hlf-production-network
}

start-org1-peer2() {
  sep
  echo "Starting Org1 Peer2"
  sep

  kubectl create -f "$K8S/org1-peer2/org1-peer2.yaml" -n hlf-production-network
  kubectl create -f "$K8S/org1-peer2/org1-peer2-service.yaml" -n hlf-production-network
  kubectl wait --for=condition=ready pod -l app=peer2-org1 --timeout=120s -n hlf-production-network
}

start-org2-peer1() {
  sep
  echo "Starting Org2 Peer1"
  sep

  kubectl create -f "$K8S/org2-peer1/org2-peer1.yaml" -n hlf-production-network
  kubectl create -f "$K8S/org2-peer1/org2-peer1-service.yaml" -n hlf-production-network
  kubectl wait --for=condition=ready pod -l app=peer1-org2 --timeout=120s -n hlf-production-network
}

start-org2-peer2() {
  sep
  echo "Starting Org2 Peer2"
  sep

  kubectl create -f "$K8S/org2-peer2/org2-peer2.yaml" -n hlf-production-network
  kubectl create -f "$K8S/org2-peer2/org2-peer2-service.yaml" -n hlf-production-network
  kubectl wait --for=condition=ready pod -l app=peer2-org2 --timeout=120s -n hlf-production-network

}

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
setup-org1-ca
setup-org2-ca
enroll-org1-peers
enroll-org2-peers
start-org1-peer1
start-org1-peer2
start-org2-peer1
start-org2-peer2
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
