source ./util.sh

header "Org1 CA"

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
export CA_ORG1_HOST=$(minikube service rca-org1 --url -n hlf-production-network | cut -c 8-)
echo "Org1 CA service exposed on $CA_ORG1_HOST"
small_sep

# Wait until pod is ready
echo "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=rca-org1-root --timeout=120s -n hlf-production-network
sleep $SERVER_STARTUP_TIME
export ORG1_CA_NAME=$(get_pods "rca-org1-root")
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