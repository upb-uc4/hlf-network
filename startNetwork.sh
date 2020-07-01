# Color definitions for better readability
CYAN=$(tput setaf 6)
NORMAL=$(tput sgr0)

# Function definitions
get_pods() {
  #1 - app name
  kubectl get pods -l app=$1 --field-selector status.phase=Running -n hlf-production-network --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | head -n 1
}

small_sep() {
  printf "%s" "${CYAN}"
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
  printf "%s" "${NORMAL}"
}

sep() {
  printf "%s" "${CYAN}"
  printf '%*s\n' "${COLUMN:-$(tput cols)}" '' | tr ' ' =
  printf "%s" "${NORMAL}"
}

command() {
  #1 - command to display
  echo "${CYAN}$1${NORMAL}"
}

setup-tls-ca() {
  sep
  command "TLS CA"
  sep

  # Create deployment for tls root ca
  if (($(kubectl get deployment -l app=ca-tls-root --ignore-not-found -n hlf-production-network | wc -l) < 2)); then
    command "Creating TLS CA deployment"
    kubectl create -f $K8S/tls-ca/tls-ca.yaml -n hlf-production-network
  else
    command "TLS CA deployment already exists"
  fi

  # Expose service for tls root ca
  if (($(kubectl get service -l app=ca-tls-root --ignore-not-found  -n hlf-production-network| wc -l) < 2)); then
    command "Creating TLS CA service"
    kubectl create -f $K8S/tls-ca/tls-ca-service.yaml -n hlf-production-network
  else
    command "TLS CA service already exists"
  fi
  CA_TLS_HOST=$(minikube service ca-tls --url -n hlf-production-network | cut -c 8-)
  command "TLS CA service exposed on $CA_TLS_HOST"
  small_sep

  # Wait until pod and service are ready
  command "Waiting for pod"
  kubectl wait --for=condition=ready pod -l app=ca-tls-root --timeout=60s -n hlf-production-network
  TLS_CA_NAME=$(get_pods "ca-tls-root")
  command "Using pod $TLS_CA_NAME"
  small_sep

  # Copy TLS certificate into local tmp folder
  command "Copy TLS certificate to local folder"
  export FABRIC_CA_CLIENT_TLS_CERTFILES=tls-ca-cert.pem
  export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/tls-ca/admin
  mkdir -p $TMP_FOLDER
  mkdir -p $FABRIC_CA_CLIENT_HOME
  cp $TMP_FOLDER/hyperledger/tls-ca/crypto/ca-cert.pem $TMP_FOLDER/ca-cert.pem

  # Query TLS CA server to enroll an admin identity
  command "Use CA-client to enroll admin"
  small_sep
  cp $TMP_FOLDER/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES
  ./$CA_CLIENT enroll $DEBUG -u https://tls-ca-admin:tls-ca-adminpw@$CA_TLS_HOST
  small_sep

  # Query TLS CA server to register other identities
  command "Use CA-client to register identities"
  small_sep
  ./$CA_CLIENT register $DEBUG --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://$CA_TLS_HOST
  small_sep
  ./$CA_CLIENT register $DEBUG --id.name peer2-org1 --id.secret peer2PW --id.type peer -u https://$CA_TLS_HOST
  small_sep
  ./$CA_CLIENT register $DEBUG --id.name peer1-org2 --id.secret peer1PW --id.type peer -u https://$CA_TLS_HOST
  small_sep
  ./$CA_CLIENT register $DEBUG --id.name peer2-org2 --id.secret peer2PW --id.type peer -u https://$CA_TLS_HOST
  small_sep
  ./$CA_CLIENT register $DEBUG --id.name orderer1-org0 --id.secret ordererPW --id.type orderer -u https://$CA_TLS_HOST
}

setup-orderer-org-ca() {
  sep
  command "Orderer Org CA"
  sep

  # Create deployment for orderer org ca
  if (($(kubectl get deployment -l app=rca-org0-root --ignore-not-found  -n hlf-production-network| wc -l) < 2)); then
    command "Creating Orderer Org CA deployment"
    kubectl create -f $K8S/orderer-org-ca/orderer-org-ca.yaml -n hlf-production-network
  else
    command "Orderer Org CA deployment already exists"
  fi

  # Expose service for orderer org ca
  if (($(kubectl get service -l app=rca-org0-root --ignore-not-found  -n hlf-production-network| wc -l) < 2)); then
    command "Creating Orderer Org CA service"
    kubectl create -f $K8S/orderer-org-ca/orderer-org-ca-service.yaml -n hlf-production-network
  else
    command "Orderer Org CA service already exists"
  fi
  CA_ORDERER_HOST=$(minikube service rca-org0 --url  -n hlf-production-network| cut -c 8-)
  command "Orderer Org CA service exposed on $CA_ORDERER_HOST"
  small_sep

  # Wait until pod is ready
  command "Waiting for pod"
  kubectl wait --for=condition=ready pod -l app=rca-org0-root --timeout=60s -n hlf-production-network
  ORDERER_ORG_CA_NAME=$(get_pods "rca-org0-root")
  command "Using pod $ORDERER_ORG_CA_NAME"
  small_sep

  export FABRIC_CA_CLIENT_TLS_CERTFILES=../crypto/ca-cert.pem
  export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org0/ca/admin
  mkdir -p $FABRIC_CA_CLIENT_HOME

  # Query Orderrer CA server to enroll an admin identity
  command "Use CA-client to enroll admin"
  small_sep
  ./$CA_CLIENT enroll $DEBUG -u https://rca-org0-admin:rca-org0-adminpw@$CA_ORDERER_HOST
  small_sep

  # Query TLS CA server to register other identities
  command "Use CA-client to register identities"
  small_sep
  # The id.secret password ca be used to enroll the registered users lateron
  ./$CA_CLIENT register $DEBUG --id.name orderer1-org0 --id.secret ordererpw --id.type orderer -u https://$CA_ORDERER_HOST
  small_sep
  ./$CA_CLIENT register $DEBUG --id.name admin-org0 --id.secret org0adminpw --id.type admin --id.attrs "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert" -u https://$CA_ORDERER_HOST
}

setup-org1-ca() {
  sep
  command "Org1 CA"
  sep

  # Create deployment for org1 ca
  if (($(kubectl get deployment -l app=rca-org1-root --ignore-not-found  -n hlf-production-network| wc -l) < 2)); then
    command "Creating Org1 CA deployment"
    kubectl create -f $K8S/org1-ca/org1-ca.yaml -n hlf-production-network
  else
    command "Org1 CA deployment already exists"
  fi

  # Expose service for org1 ca
  if (($(kubectl get service -l app=rca-org1-root --ignore-not-found  -n hlf-production-network| wc -l) < 2)); then
    command "Creating Org1 CA service"
    kubectl create -f $K8S/org1-ca/org1-ca-service.yaml -n hlf-production-network
  else
    command "Org1 CA service already exists"
  fi
  CA_ORG1_HOST=$(minikube service rca-org1 --url  -n hlf-production-network| cut -c 8-)
  command "Org1 CA service exposed on $CA_ORG1_HOST"
  small_sep

  # Wait until pod is ready
  command "Waiting for pod"
  kubectl wait --for=condition=ready pod -l app=rca-org1-root --timeout=60s -n hlf-production-network
  ORG1_CA_NAME=$(get_pods "rca-org1-root")
  command "Using pod $ORG1_CA_NAME"
  small_sep

  export FABRIC_CA_CLIENT_TLS_CERTFILES=../crypto/ca-cert.pem
  export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org1/ca/admin
  mkdir -p $FABRIC_CA_CLIENT_HOME

  # Query TLS CA server to enroll an admin identity
  command "Use CA-client to enroll admin"
  small_sep
  ./$CA_CLIENT enroll $DEBUG -u https://rca-org1-admin:rca-org1-adminpw@$CA_ORG1_HOST
  small_sep

  # Query TLS CA server to register other identities
  command "Use CA-client to register identities"
  small_sep
  # The id.secret password ca be used to enroll the registered users lateron
  ./$CA_CLIENT register $DEBUG --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://$CA_ORG1_HOST
  small_sep
  ./$CA_CLIENT register $DEBUG --id.name peer2-org1 --id.secret peer2PW --id.type peer -u https://$CA_ORG1_HOST
  small_sep
  ./$CA_CLIENT register $DEBUG --id.name admin-org1 --id.secret org1AdminPW --id.type user -u https://$CA_ORG1_HOST
  small_sep
  ./$CA_CLIENT register $DEBUG --id.name user-org1 --id.secret org1UserPW --id.type user -u https://$CA_ORG1_HOST
}

setup-org2-ca() {
  sep
  command "Org2 CA"
  sep

  # Create deployment for org2 ca
  if (($(kubectl get deployment -l app=rca-org2-root --ignore-not-found -n hlf-production-network | wc -l) < 2)); then
    command "Creating Org2 CA deployment"
    kubectl create -f $K8S/org2-ca/org2-ca.yaml -n hlf-production-network
  else
    command "Org2 CA deployment already exists"
  fi

  # Expose service for org2 ca
  if (($(kubectl get service -l app=rca-org2-root --ignore-not-found -n hlf-production-network | wc -l) < 2)); then
    command "Creating Org2 CA service"
    kubectl create -f $K8S/org2-ca/org2-ca-service.yaml -n hlf-production-network
  else
    command "Org2 CA service already exists"
  fi
  CA_ORG2_HOST=$(minikube service rca-org2 --url -n hlf-production-network | cut -c 8-)
  command "Org2 CA service exposed on $CA_ORG2_HOST"
  small_sep

  # Wait until pod is ready
  command "Waiting for pod"
  kubectl wait --for=condition=ready pod -l app=rca-org2-root --timeout=60s -n hlf-production-network
  ORG2_CA_NAME=$(get_pods "rca-org2-root")
  command "Using pod $ORG2_CA_NAME"
  small_sep

  export FABRIC_CA_CLIENT_TLS_CERTFILES=../crypto/ca-cert.pem
  export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org2/ca/admin
  mkdir -p $FABRIC_CA_CLIENT_HOME

  # Query TLS CA server to enroll an admin identity
  command "Use CA-client to enroll admin"
  small_sep
  ./$CA_CLIENT enroll $DEBUG -u https://rca-org2-admin:rca-org2-adminpw@$CA_ORG2_HOST
  small_sep

  # Query TLS CA server to register other identities
  command "Use CA-client to register identities"
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
  command "Org1 Peer1"
  sep

  command "Enroll Peer1 at Org1-CA"

  export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org1/peer1
  export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/ca/org1-ca-cert.pem
  export FABRIC_CA_CLIENT_MSPDIR=msp

  # We need to copy the certificate of Org1-CA into our tmp directory
  mkdir -p $FABRIC_CA_CLIENT_HOME/assets/ca
  cp $TMP_FOLDER/hyperledger/org1/ca/crypto/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES

  ./$CA_CLIENT enroll $DEBUG -u https://peer1-org1:peer1PW@$CA_ORG1_HOST

  small_sep

  command "Enroll Peer1 at TLS-CA"

  export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/tls-ca/tls-ca-cert.pem

  # We need to copy the certificate of the TLS CA into our tmp directory
  mkdir -p $FABRIC_CA_CLIENT_HOME/assets/tls-ca
  cp $TMP_FOLDER/hyperledger/tls-ca/admin/tls-ca-cert.pem $FABRIC_CA_CLIENT_HOME/assets/tls-ca/tls-ca-cert.pem

  export FABRIC_CA_CLIENT_MSPDIR=tls-msp
  ./$CA_CLIENT enroll $DEBUG -u https://peer1-org1:peer1PW@$CA_TLS_HOST --enrollment.profile tls --csr.hosts peer1-org1

  mv $TMP_FOLDER/hyperledger/org1/peer1/tls-msp/keystore/*_sk $TMP_FOLDER/hyperledger/org1/peer1/tls-msp/keystore/key.pem



  # Enroll peer 2

  sep
  command "Org1 Peer2"
  sep

  command "Enroll Peer2 at Org1-CA"

  export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org1/peer2
  export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/ca/org1-ca-cert.pem
  export FABRIC_CA_CLIENT_MSPDIR=msp

  # We need to copy the certificate of Org1-CA into our tmp directory
  mkdir -p $FABRIC_CA_CLIENT_HOME/assets/ca
  cp $TMP_FOLDER/hyperledger/org1/ca/crypto/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES

  ./$CA_CLIENT enroll $DEBUG -u https://peer2-org1:peer2PW@$CA_ORG1_HOST

  small_sep

  command "Enroll Peer2 at TLS-CA"

  export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/tls-ca/tls-ca-cert.pem

  # We need to copy the certificate of the TLS CA into our tmp directory
  mkdir -p $FABRIC_CA_CLIENT_HOME/assets/tls-ca
  cp $TMP_FOLDER/hyperledger/tls-ca/admin/tls-ca-cert.pem $FABRIC_CA_CLIENT_HOME/assets/tls-ca/tls-ca-cert.pem

  export FABRIC_CA_CLIENT_MSPDIR=tls-msp
  ./$CA_CLIENT enroll $DEBUG -u https://peer2-org1:peer2PW@$CA_TLS_HOST --enrollment.profile tls --csr.hosts peer2-org1

  mv $TMP_FOLDER/hyperledger/org1/peer2/tls-msp/keystore/*_sk $TMP_FOLDER/hyperledger/org1/peer2/tls-msp/keystore/key.pem



  # Enroll Org1 admin

  sep
  command "Org1 Admin"
  sep

  command "Enroll org1 admin identity"

  # Note that we assume that peer 1 holds the admin identity
  export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org1/admin
  export FABRIC_CA_CLIENT_TLS_CERTFILES=../../org1/peer1/assets/ca/org1-ca-cert.pem
  export FABRIC_CA_CLIENT_MSPDIR=msp
  ./$CA_CLIENT enroll $DEBUG -u https://admin-org1:org1AdminPW@$CA_ORG1_HOST

  small_sep

  command "Distribute admin certificate across peers"

  mkdir $TMP_FOLDER/hyperledger/org1/peer1/msp/admincerts
  cp $TMP_FOLDER/hyperledger/org1/admin/msp/signcerts/cert.pem $TMP_FOLDER/hyperledger/org1/peer1/msp/admincerts/org1-admin-cert.pem

  # usually this would happen out-of-band
  mkdir $TMP_FOLDER/hyperledger/org1/peer2/msp/admincerts
  cp $TMP_FOLDER/hyperledger/org1/admin/msp/signcerts/cert.pem $TMP_FOLDER/hyperledger/org1/peer2/msp/admincerts/org1-admin-cert.pem
}

enroll-org2-peers() {
  # Enroll peer 1

  sep
  command "Org2 Peer1"
  sep

  command "Enroll Peer1 at Org2-CA"

  export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org2/peer1
  export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/ca/org2-ca-cert.pem
  export FABRIC_CA_CLIENT_MSPDIR=msp

  # We need to copy the certificate of Org2-CA into our tmp directory
  mkdir -p $FABRIC_CA_CLIENT_HOME/assets/ca
  cp $TMP_FOLDER/hyperledger/org2/ca/crypto/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES

  ./$CA_CLIENT enroll $DEBUG -u https://peer1-org2:peer1PW@$CA_ORG2_HOST

  small_sep

  command "Enroll Peer1 at TLS-CA"

  export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/tls-ca/tls-ca-cert.pem

  # We need to copy the certificate of the TLS CA into our tmp directory
  mkdir -p $FABRIC_CA_CLIENT_HOME/assets/tls-ca
  cp $TMP_FOLDER/hyperledger/tls-ca/admin/tls-ca-cert.pem $FABRIC_CA_CLIENT_HOME/assets/tls-ca/tls-ca-cert.pem

  export FABRIC_CA_CLIENT_MSPDIR=tls-msp
  ./$CA_CLIENT enroll $DEBUG -u https://peer1-org2:peer1PW@$CA_TLS_HOST --enrollment.profile tls --csr.hosts peer1-org2

  mv $TMP_FOLDER/hyperledger/org2/peer1/tls-msp/keystore/*_sk $TMP_FOLDER/hyperledger/org2/peer1/tls-msp/keystore/key.pem

  # Enroll peer 2

  sep
  command "Org2 Peer2"
  sep

  command "Enroll Peer2 at Org2-CA"

  export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org2/peer2
  export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/ca/org2-ca-cert.pem
  export FABRIC_CA_CLIENT_MSPDIR=msp

  # We need to copy the certificate of Org2-CA into our tmp directory
  mkdir -p $FABRIC_CA_CLIENT_HOME/assets/ca
  cp $TMP_FOLDER/hyperledger/org2/ca/crypto/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES

  ./$CA_CLIENT enroll $DEBUG -u https://peer2-org2:peer2PW@$CA_ORG2_HOST

  small_sep

  command "Enroll Peer2 at TLS-CA"

  export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/tls-ca/tls-ca-cert.pem

  # We need to copy the certificate of the TLS CA into our tmp directory
  mkdir -p $FABRIC_CA_CLIENT_HOME/assets/tls-ca
  cp $TMP_FOLDER/hyperledger/tls-ca/admin/tls-ca-cert.pem $FABRIC_CA_CLIENT_HOME/assets/tls-ca/tls-ca-cert.pem

  export FABRIC_CA_CLIENT_MSPDIR=tls-msp
  ./$CA_CLIENT enroll $DEBUG -u https://peer2-org2:peer2PW@$CA_TLS_HOST --enrollment.profile tls --csr.hosts peer2-org2

  mv $TMP_FOLDER/hyperledger/org2/peer2/tls-msp/keystore/*_sk $TMP_FOLDER/hyperledger/org2/peer2/tls-msp/keystore/key.pem

  # Enroll Org2 admin

  sep
  command "Org2 Admin"
  sep

  command "Enroll org2 admin identity"

  # Note that we assume that peer 1 holds the admin identity
  export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org2/admin
  export FABRIC_CA_CLIENT_TLS_CERTFILES=../../org2/peer1/assets/ca/org2-ca-cert.pem
  export FABRIC_CA_CLIENT_MSPDIR=msp
  ./$CA_CLIENT enroll $DEBUG -u https://admin-org2:org2AdminPW@$CA_ORG2_HOST

  small_sep

  command "Distribute admin certificate across peers"

  mkdir $TMP_FOLDER/hyperledger/org2/peer1/msp/admincerts
  cp $TMP_FOLDER/hyperledger/org2/admin/msp/signcerts/cert.pem $TMP_FOLDER/hyperledger/org2/peer1/msp/admincerts/org2-admin-cert.pem

  # usually this would happen out-of-band
  mkdir $TMP_FOLDER/hyperledger/org2/peer2/msp/admincerts
  cp $TMP_FOLDER/hyperledger/org2/admin/msp/signcerts/cert.pem $TMP_FOLDER/hyperledger/org2/peer2/msp/admincerts/org2-admin-cert.pem
}

start-org1-peer1(){
  sep
  command "Starting Org1 Peer1"
  sep

  kubectl create -f "$K8S/org1-peer1/org1-peer1.yaml" -n hlf-production-network
}

start-org1-peer2(){
  sep
  command "Starting Org1 Peer2"
  sep

  kubectl create -f "$K8S/org1-peer2/org1-peer2.yaml" -n hlf-production-network
}

start-org2-peer1(){
  sep
  command "Starting Org2 Peer1"
  sep

  kubectl create -f "$K8S/org2-peer1/org2-peer1.yaml" -n hlf-production-network
}

start-org2-peer2(){
  sep
  command "Starting Org2 Peer2"
  sep

  kubectl create -f "$K8S/org2-peer2/org2-peer2.yaml" -n hlf-production-network
}

# Debug commands using -d flag
export DEBUG=""
if [[ $1 == "-d" ]]; then
  command "Debug mode activated"
  export DEBUG="-d"
fi

# Set environment variables
source ./env.sh

# Use configuration file to generate kubernetes setup from the template
./apply-config.sh

# Start minikube
if minikube status | grep -q 'host: Stopped'; then
  command "Starting Network"
  minikube start
fi

mkdir -p $TMP_FOLDER/hyperledger

# Mount tmp folder
small_sep
command "Mounting tmp folder to minikube"
minikube mount $TMP_FOLDER/hyperledger:/hyperledger &

small_sep
kubectl create -f $K8S/namespace.yaml
kubectl wait --for=condition=ready namespace -f $K8S/namespace.yaml --timeout=60s

setup-tls-ca
setup-orderer-org-ca
setup-org1-ca
setup-org2-ca
enroll-org1-peers
enroll-org2-peers
start-org1-peer1
start-org1-peer2
start-org2-peer1
start-org2-peer2


sep

echo -e "Done. Execute \e[2mminikube dashboard\e[22m to open the dashboard or run \e[2m./deleteNetwork.sh\e[22m to shutdown and delete the network."
