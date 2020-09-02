source ./util.sh

header "Starting Docker in Docker in Kubernetes"

mkdir -p $TMP_FOLDER/hyperledger/dind

kubectl create -f "$K8S/dind/dind.yaml" -n hlf-production-network
kubectl create -f "$K8S/dind/dind-service.yaml" -n hlf-production-network
kubectl wait --for=condition=ready pod -l app=dind --timeout=120s -n hlf-production-network
