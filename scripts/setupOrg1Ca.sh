source ./util.sh

header "Org1 CA"

# Create deployment for org1 ca
echo "Creating Org1 CA deployment"
kubectl create -f $K8S/org1-ca/org1-ca.yaml -n hlf-production-network

# Expose service for org1 ca
echo "Creating Org1 CA service"
kubectl create -f $K8S/org1-ca/org1-ca-service.yaml -n hlf-production-network

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

# TODO share trusted root certificate as secret
cp $TMP_FOLDER/ca-cert.pem $TMP_FOLDER/hyperledger/org1/ca/

kubectl exec -n hlf-production-network $(get_pods "rca-org1-root") -i -- bash /tmp/hyperledger/scripts/podStart/registerOrg1CaUsers.sh
