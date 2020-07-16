# Set environment variables

source ./env.sh

# Make sure minikube is running
if minikube status | grep -q 'host: Stopped'; then
  minikube start
fi

# Delete namespace and all contained resources
kubectl delete -f $K8S/namespace.yaml

echo Delete temporary directories
rm -rf $TMP_FOLDER
rm -rf $K8S
