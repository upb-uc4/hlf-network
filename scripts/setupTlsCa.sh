source ./util.sh

sep
echo "TLS CA"
sep

# Create deployment for tls root ca
if (($(kubectl get deployment -l app=ca-tls-root --ignore-not-found -n hlf-production-network | wc -l) < 2)); then
  echo "Creating TLS CA deployment"
  kubectl create -f $K8S/tls-ca/tls-ca.yaml -n hlf-production-network
else
  echo "TLS CA deployment already exists"
fi

# Expose service for tls root ca
if (($(kubectl get service -l app=ca-tls-root --ignore-not-found -n hlf-production-network | wc -l) < 2)); then
  echo "Creating TLS CA service"
  kubectl create -f $K8S/tls-ca/tls-ca-service.yaml -n hlf-production-network
else
  echo "TLS CA service already exists"
fi
export CA_TLS_HOST=$(minikube service ca-tls --url -n hlf-production-network | cut -c 8-)
echo "TLS CA service exposed on $CA_TLS_HOST"
small_sep

# Wait until pod and service are ready
echo "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=ca-tls-root --timeout=120s -n hlf-production-network
sleep $SERVER_STARTUP_TIME
export TLS_CA_NAME=$(get_pods "ca-tls-root")
echo "Using pod $TLS_CA_NAME"
small_sep

# Copy TLS certificate into local tmp folder
echo "Copy TLS certificate to local folder"
export FABRIC_CA_CLIENT_TLS_CERTFILES=tls-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/tls-ca/admin
mkdir -p $TMP_FOLDER
mkdir -p $FABRIC_CA_CLIENT_HOME
cp $TMP_FOLDER/hyperledger/tls-ca/crypto/ca-cert.pem $TMP_FOLDER/ca-cert.pem

# Query TLS CA server to enroll an admin identity
echo "Use CA-client to enroll admin"
small_sep
cp $TMP_FOLDER/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES
./$CA_CLIENT enroll $DEBUG -u https://tls-ca-admin:tls-ca-adminpw@$CA_TLS_HOST
small_sep

# Query TLS CA server to register other identities
echo "Use CA-client to register identities"
small_sep
./$CA_CLIENT register $DEBUG --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://$CA_TLS_HOST
small_sep
./$CA_CLIENT register $DEBUG --id.name peer2-org1 --id.secret peer2PW --id.type peer -u https://$CA_TLS_HOST
small_sep
./$CA_CLIENT register $DEBUG --id.name peer1-org2 --id.secret peer1PW --id.type peer -u https://$CA_TLS_HOST
small_sep
./$CA_CLIENT register $DEBUG --id.name peer2-org2 --id.secret peer2PW --id.type peer -u https://$CA_TLS_HOST
small_sep
./$CA_CLIENT register $DEBUG --id.name orderer-org0 --id.secret ordererPW --id.type orderer -u https://$CA_TLS_HOST