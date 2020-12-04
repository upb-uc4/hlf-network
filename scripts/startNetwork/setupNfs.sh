source ./scripts/util.sh
source ./scripts/env.sh

kubectl apply -f k8s/nfs/nfs.yaml -n hlf
kubectl apply -f k8s/nfs/nfs-service.yaml -n hlf
kubectl apply -f k8s/nfs/nfs-test-pv.yaml
kubectl apply -f k8s/nfs/nfs-test-pvc.yaml -n hlf