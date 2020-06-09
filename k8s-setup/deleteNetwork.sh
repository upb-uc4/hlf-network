# Set environment variables

source ./env.sh

# Delete CA Server
kubectl delete -f tls-ca.yaml

# Delete CA Service
kubectl delete -f tls-ca-service.yaml

# Remove tmp dir
rm -rf $TMP_FOLDER
