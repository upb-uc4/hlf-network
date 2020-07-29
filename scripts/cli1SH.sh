get_pods() {
  #1 - app name
  kubectl get pods -l app=$1 --field-selector status.phase=Running -n hlf-production-network --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | head -n 1
}

CLI1=$(get_pods "cli-org1")

# Use CLI shell
kubectl exec -n hlf-production-network $CLI1 -it -- sh