source ./util.sh

sep
echo "Orderer Org CA"
sep

# Create deployment for orderer org ca
if (($(kubectl get deployment -l app=rca-org0-root --ignore-not-found -n hlf-production-network | wc -l) < 2)); then
  echo "Creating Orderer Org CA deployment"
  kubectl create -f $K8S/orderer-org-ca/orderer-org-ca.yaml -n hlf-production-network
else
  echo "Orderer Org CA deployment already exists"
fi

# Expose service for orderer org ca
if (($(kubectl get service -l app=rca-org0-root --ignore-not-found -n hlf-production-network | wc -l) < 2)); then
  echo "Creating Orderer Org CA service"
  kubectl create -f $K8S/orderer-org-ca/orderer-org-ca-service.yaml -n hlf-production-network
else
  echo "Orderer Org CA service already exists"
fi

# TODO Remove minikube-specific access
export CA_ORDERER_HOST=$(minikube service rca-org0 --url -n hlf-production-network | cut -c 8-)
echo "Orderer Org CA service exposed on $CA_ORDERER_HOST"
small_sep

# Wait until pod is ready
echo "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=rca-org0-root --timeout=120s -n hlf-production-network
sleep $SERVER_STARTUP_TIME
export ORDERER_ORG_CA_NAME=$(get_pods "rca-org0-root")
echo "Using pod $ORDERER_ORG_CA_NAME"
small_sep

export FABRIC_CA_CLIENT_TLS_CERTFILES=../crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=$TMP_FOLDER/hyperledger/org0/ca/admin
mkdir -p $FABRIC_CA_CLIENT_HOME

# Query Orderrer CA server to enroll an admin identity
echo "Use CA-client to enroll admin"
small_sep
./$CA_CLIENT enroll $DEBUG -u https://rca-org0-admin:rca-org0-adminpw@$CA_ORDERER_HOST
small_sep

# Query TLS CA server to register other identities
echo "Use CA-client to register identities"
small_sep
# The id.secret password ca be used to enroll the registered users lateron
./$CA_CLIENT register $DEBUG --id.name orderer-org0 --id.secret ordererpw --id.type orderer -u https://$CA_ORDERER_HOST
small_sep
./$CA_CLIENT register $DEBUG --id.name admin-org0 --id.secret org0adminpw --id.type admin --id.attrs "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert" -u https://$CA_ORDERER_HOST
