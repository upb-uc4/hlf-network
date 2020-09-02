source ./util.sh
source ./env.sh

header "Starting Docker in Docker in Kubernetes"

mkdir -p $TMP_FOLDER/hyperledger/dind

kubectl create -f "$K8S/dind/dind.yaml" -n hlf-production-network
kubectl create -f "$K8S/dind/dind-service.yaml" -n hlf-production-network
kubectl wait --for=condition=ready pod -l app=dind --timeout=${CONTAINER_TIMEOUT} -n hlf-production-network
