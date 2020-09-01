header "Enroll peers and orderer"

# TODO use secrete for distribution of root certificate
kubectl create -f $K8S/enroll-peers-org1.yaml -n hlf-production-network
kubectl create -f $K8S/enroll-peers-org2.yaml -n hlf-production-network
kubectl wait --for=condition=complete job -l app=enroll-peers --timeout=120s -n hlf-production-network

