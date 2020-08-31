source ./util.sh

header "TLS CA"

# Create deployment for tls root ca
echo "Creating TLS CA deployment"
kubectl create -f $K8S/tls-ca/tls-ca.yaml -n hlf-production-network


# Expose service for tls root ca
echo "Creating TLS CA service"
kubectl create -f $K8S/tls-ca/tls-ca-service.yaml -n hlf-production-network

# Wait until pod and service are ready
echo "Waiting for pod"
kubectl wait --for=condition=ready pod -l app=ca-tls-root --timeout=120s -n hlf-production-network
sleep $SERVER_STARTUP_TIME

kubectl exec -n hlf-production-network $(get_pods "ca-tls-root") -i -- bash /tmp/hyperledger/scripts/podStart/registerTLSusers.sh

cp $TMP_FOLDER/hyperledger/tls-ca/crypto/ca-cert.pem $TMP_FOLDER/ca-cert.pem
