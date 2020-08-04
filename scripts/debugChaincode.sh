get_pods() {
  #1 - app name
  kubectl get pods -l app=$1 --field-selector status.phase=Running -n hlf-production-network --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | head -n 1
}

# Exit on errors
set -e

source ./env.sh

kubectl exec -n hlf-production-network $(get_pods "cli-org1") -i -- sh < scripts/debug/queryInstalledOrg1.sh
kubectl exec -n hlf-production-network $(get_pods "cli-org2") -i -- sh < scripts/debug/queryInstalledOrg2.sh
