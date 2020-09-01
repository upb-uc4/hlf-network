source ./util.sh

header "Org2 CA"

# Create deployment for org2 ca
echo "Creating Org2 CA deployment"
kubectl create -f $K8S/org2-ca/org2-ca.yaml -n hlf-production-network

# Expose service for org2 ca
echo "Creating Org2 CA service"
kubectl create -f $K8S/org2-ca/org2-ca-service.yaml -n hlf-production-network

small_sep

# Wait until pod is ready
echo "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=rca-org2-root --timeout=120s -n hlf-production-network
sleep $SERVER_STARTUP_TIME
export ORG2_CA_NAME=$(get_pods "rca-org2-root")
echo "Using pod $ORG2_CA_NAME"
small_sep

# TODO share trusted root certificate as secret
cp $TMP_FOLDER/ca-cert.pem $TMP_FOLDER/hyperledger/org2/ca/

kubectl exec -n hlf-production-network $(get_pods "rca-org2-root") -i -- bash /tmp/hyperledger/scripts/podStart/registerOrg2CaUsers.sh