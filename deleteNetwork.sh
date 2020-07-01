# Set environment variables

source ./env.sh

kubectl delete -f $K8S/namespace.yaml

echo Delete temporary directories
rm -rf $TMP_FOLDER
rm -rf $K8S
