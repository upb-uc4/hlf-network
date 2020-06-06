# Set environment variables

source ./env.sh

# Delete CA Server
kubectl delete -f tls-ca-server.yaml

# Remove tmp dir
rm -rf $TMP_FOLDER
