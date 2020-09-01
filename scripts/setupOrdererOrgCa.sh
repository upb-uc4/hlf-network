source ./util.sh

header "Orderer Org CA"

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

# Wait until pod is ready
echo "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=rca-org0-root --timeout=120s -n hlf-production-network
sleep $SERVER_STARTUP_TIME

# TODO share trusted root certificate as secret
cp $TMP_FOLDER/ca-cert.pem $TMP_FOLDER/hyperledger/tls-ca/

kubectl exec -n hlf-production-network $(get_pods "rca-org0-root") -i -- bash /tmp/hyperledger/scripts/podStart/registerOrdererOrgUsers.sh

