header "Enroll peers and orderer"
source ./env.sh

# TODO use secrete for distribution of root certificate
kubectl create -f $K8S/enroll-peers-org1.yaml -n hlf-production-network
kubectl create -f $K8S/enroll-peers-org2.yaml -n hlf-production-network
kubectl wait --for=condition=complete job -l app=enroll-peers --timeout=${CONTAINER_TIMEOUT} -n hlf-production-network

