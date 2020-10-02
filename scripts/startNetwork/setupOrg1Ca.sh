source ./util.sh
source ./env.sh

header "Org1 CA"

# TODO share trusted root certificate as secret
mkdir -p $HL_MOUNT/org1/ca/
cp $HL_MOUNT/ca-cert.pem $HL_MOUNT/org1/ca/

# Create deployment for org1 ca
echo "Creating Org1 CA deployment"
kubectl create -f $K8S/org1-ca/org1-ca.yaml -n hlf-production-network

# Expose service for org1 ca
echo "Creating Org1 CA service"
kubectl create -f $K8S/org1-ca/org1-ca-service.yaml -n hlf-production-network

small_sep

# Wait until pod is ready
echo "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=rca-org1-root --timeout=${CONTAINER_TIMEOUT} -n hlf-production-network
sleep $SERVER_STARTUP_TIME
export ORG1_CA_NAME=$(get_pods "rca-org1-root")
echo "Using pod $ORG1_CA_NAME"
small_sep

kubectl exec -n hlf-production-network $(get_pods "rca-org1-root") -i -- bash /tmp/hyperledger/scripts/podStart/registerOrg1CaUsers.sh
