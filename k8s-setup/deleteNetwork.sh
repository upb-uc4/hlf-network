# Set environment variables

source ./env.sh

# Delete CA Server
echo Deleting tls root ca deployment
kubectl delete -f tls-ca.yaml
echo Waiting until all pods are terminated
kubectl wait --for=delete pod -l app=ca-tls-root --timeout=60s

# Delete CA Service
echo Deleting tls root ca service
kubectl delete -f tls-ca-service.yaml

# Remove tmp dir
echo Deleting tmp directory
rm -rf $TMP_FOLDER
