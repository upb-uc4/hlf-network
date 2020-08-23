source ./util.sh

sep
echo "Starting Org1 Peer1"
sep

kubectl create -f "$K8S/org1-peer1/org1-peer1.yaml" -n hlf-production-network
kubectl create -f "$K8S/org1-peer1/org1-peer1-service.yaml" -n hlf-production-network
kubectl wait --for=condition=ready pod -l app=peer1-org1 --timeout=120s -n hlf-production-network



sep
echo "Starting Org1 Peer2"
sep

kubectl create -f "$K8S/org1-peer2/org1-peer2.yaml" -n hlf-production-network
kubectl create -f "$K8S/org1-peer2/org1-peer2-service.yaml" -n hlf-production-network
kubectl wait --for=condition=ready pod -l app=peer2-org1 --timeout=120s -n hlf-production-network



sep
echo "Starting Org2 Peer1"
sep

kubectl create -f "$K8S/org2-peer1/org2-peer1.yaml" -n hlf-production-network
kubectl create -f "$K8S/org2-peer1/org2-peer1-service.yaml" -n hlf-production-network
kubectl wait --for=condition=ready pod -l app=peer1-org2 --timeout=120s -n hlf-production-network



sep
echo "Starting Org2 Peer2"
sep

kubectl create -f "$K8S/org2-peer2/org2-peer2.yaml" -n hlf-production-network
kubectl create -f "$K8S/org2-peer2/org2-peer2-service.yaml" -n hlf-production-network
kubectl wait --for=condition=ready pod -l app=peer2-org2 --timeout=120s -n hlf-production-network