# Function definitions

get_pods() {
    kubectl get pods -l app=ca-tls-root --field-selector status.phase=Running  --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | head -n 1
}

small_sep() {
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

sep() {
    printf '%*s\n' "${COLUMN:-$(tput cols)}" '' | tr ' ' =
}


# Set environment variables
source ./env.sh

# Start minikube
if minikube status | grep -q 'host: Stopped'; then
  echo Starting Network
  minikube start
  sep
fi



# Create deployment for tls root ca
if (($(kubectl get deployment -l app=ca-tls-root --ignore-not-found | wc -l) < 2)); then
  echo Creating TLS CA deployment
  kubectl create -f tls-ca/tls-ca.yaml
else
  echo TLS CA deployment already exists
fi



# Expose service for tls root ca
if (($(kubectl get service -l app=ca-tls-root --ignore-not-found | wc -l) < 2)); then
  echo Creating TLS CA service
  kubectl create -f tls-ca/tls-ca-service.yaml
else
  echo TLS CA service already exists
fi
CA_SERVER_HOST=$(minikube service ca-tls --url | cut -c 8-)
echo TLS CA service exposed on $CA_SERVER_HOST
sep


# Wait until pod is ready
echo Waiting for pod
kubectl wait --for=condition=ready pod -l app=ca-tls-root --timeout=60s
TLS_CA_NAME=$(get_pods)
echo Using pod $TLS_CA_NAME
sep



# Copy TLS certificate into local tmp folder
echo Copy TLS certificate to local folder
mkdir -p $TMP_FOLDER
mkdir -p $FABRIC_CA_CLIENT_HOME
kubectl cp default/$TLS_CA_NAME:etc/hyperledger/fabric-ca-server/ca-cert.pem $TMP_FOLDER/ca-cert.pem
sep


# Query TLS CA server to enroll an admin identity
echo Use CA-client to enroll admin
cp $TMP_FOLDER/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES
echo $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES
./$CA_CLIENT enroll -d -u https://tls-ca-admin:tls-ca-adminpw@$CA_SERVER_HOST
sep

# Query TLS CA server to register other identities
echo Use CA-client to register identities
small_sep
# The id.secret password ca be used to enroll the registered users lateron
./$CA_CLIENT register --id.name orderer1-uc4 --id.secret ordererPW --id.type orderer -u https://tls-ca-admin:tls-ca-adminpw@$CA_SERVER_HOST
small_sep
./$CA_CLIENT register --id.name peer1-uc4 --id.secret peerPW --id.type peer -u https://tls-ca-admin:tls-ca-adminpw@$CA_SERVER_HOST
sep


echo -e "Done. Execute \e[2mminikube dashboard\e[22m to open the dashboard or run \e[2m./deleteNetwork.sh\e[22m to shutdown and delete the network."



