# Color definitions for better readability
CYAN=$(tput setaf 6)
NORMAL=$(tput sgr0)

# Function definitions
get_pods() {
    kubectl get pods -l app=ca-tls-root --field-selector status.phase=Running  --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | head -n 1
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
  echo "${CYAN}$1${NORMAL}"
}



# Set environment variables
source ./env.sh

# Start minikube
if minikube status | grep -q 'host: Stopped'; then
  command "Starting Network"
  minikube start
fi

sep
command "TLS CA"
sep

# Create deployment for tls root ca
if (($(kubectl get deployment -l app=ca-tls-root --ignore-not-found | wc -l) < 2)); then
  command "Creating TLS CA deployment"
  kubectl create -f tls-ca/tls-ca.yaml
else
  command "TLS CA deployment already exists"
fi



# Expose service for tls root ca
if (($(kubectl get service -l app=ca-tls-root --ignore-not-found | wc -l) < 2)); then
  command "Creating TLS CA service"
  kubectl create -f tls-ca/tls-ca-service.yaml
else
  command "TLS CA service already exists"
fi
CA_SERVER_HOST=$(minikube service ca-tls --url | cut -c 8-)
command "TLS CA service exposed on $CA_SERVER_HOST"
small_sep


# Wait until pod is ready
command "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=ca-tls-root --timeout=60s
TLS_CA_NAME=$(get_pods)
command "Using pod $TLS_CA_NAME"
small_sep



# Copy TLS certificate into local tmp folder
command "Copy TLS certificate to local folder"
export FABRIC_CA_CLIENT_TLS_CERTFILES=tls-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/tls-ca/admin
mkdir -p $TMP_FOLDER
mkdir -p $FABRIC_CA_CLIENT_HOME
kubectl cp default/$TLS_CA_NAME:etc/hyperledger/fabric-ca-server/ca-cert.pem $TMP_FOLDER/ca-cert.pem
small_sep


# Query TLS CA server to enroll an admin identity
command "Use CA-client to enroll admin"
small_sep
cp $TMP_FOLDER/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES
./$CA_CLIENT enroll -d -u https://tls-ca-admin:tls-ca-adminpw@$CA_SERVER_HOST
small_sep

# Query TLS CA server to register other identities
command "Use CA-client to register identities"
small_sep
# The id.secret password ca be used to enroll the registered users lateron
./$CA_CLIENT register --id.name orderer1-uc4 --id.secret ordererPW --id.type orderer -u https://tls-ca-admin:tls-ca-adminpw@$CA_SERVER_HOST
small_sep
./$CA_CLIENT register --id.name peer1-uc4 --id.secret peerPW --id.type peer -u https://tls-ca-admin:tls-ca-adminpw@$CA_SERVER_HOST

sep
command "Orderer Org CA"
sep

# Create deployment for orderer org ca
if (($(kubectl get deployment -l app=rca-org0-root --ignore-not-found | wc -l) < 2)); then
  command "Creating Orderer Org CA deployment"
  kubectl create -f orderer-org-ca/orderer-org-ca.yaml
else
  command "Orderer Org CA deployment already exists"
fi



# Expose service for orderer org ca
if (($(kubectl get service -l app=rca-org0-root --ignore-not-found | wc -l) < 2)); then
  command "Creating Orderer Org CA service"
  kubectl create -f orderer-org-ca/orderer-org-ca-service.yaml
else
  command "Orderer Org CA service already exists"
fi
# lokale Variable?
CA_ORDERER_HOST=$(minikube service rca-org0 --url | cut -c 8-)
command "Orderer Org CA service exposed on $CA_ORDERER_HOST"
small_sep


# Wait until pod is ready
command "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=rca-org0-root --timeout=60s
ORDERER_ORG_CA_NAME=$(get_pods)
command "Using pod $ORDERER_ORG_CA_NAME"
small_sep


# Enroll Orderer Org's CA Admin

export FABRIC_CA_CLIENT_TLS_CERTFILES=ca-cert.pem
export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org0/ca/admin
mkdir -p $FABRIC_CA_CLIENT_HOME

# Query TLS CA server to enroll an admin identity
command "Use CA-client to enroll admin"
small_sep
cp $TMP_FOLDER/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES
./$CA_CLIENT enroll -d -u https://rca-org0-admin:rca-org0-adminpw@$CA_ORDERER_HOST
small_sep

# Query TLS CA server to register other identities
command "Use CA-client to register identities"
small_sep
# The id.secret password ca be used to enroll the registered users lateron
./$CA_CLIENT register -d --id.name orderer1-org0 --id.secret ordererpw --id.type orderer -u https://$CA_ORDERER_HOST
small_sep
./$CA_CLIENT register -d --id.name admin-org0 --id.secret org0adminpw --id.type admin --id.attrs "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert" -u https://$CA_ORDERER_HOST

sep

echo -e "Done. Execute \e[2mminikube dashboard\e[22m to open the dashboard or run \e[2m./deleteNetwork.sh\e[22m to shutdown and delete the network."
