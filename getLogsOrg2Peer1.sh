get_pods() {
  #1 - app name
  kubectl get pods -l app=$1 --field-selector status.phase=Running -n hlf-production-network --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | head -n 1
}

POD=$(get_pods "peer1-org2")

echo "Org2-Peer1 log"

kubectl logs $POD -n hlf-production-network