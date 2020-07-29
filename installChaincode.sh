# Exit on errors
set -e

source ./env.sh

mkdir $TMP_FOLDER/hyperledger/chaincode
wget -c https://github.com/upb-uc4/University-Credits-4.0/archive/v0.4.3.tar.gz -O - | tar -xz -C $TMP_FOLDER/hyperledger/chaincode --strip-components=1


get_pods() {
  #1 - app name
  kubectl get pods -l app=$1 --field-selector status.phase=Running -n hlf-production-network --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | head -n 1
}


kubectl exec -n hlf-production-network $(get_pods "cli-org1") -i -- sh < scripts/installChaincodeOrg1.sh
kubectl exec -n hlf-production-network $(get_pods "cli-org2") -i -- sh < scripts/installChaincodeOrg2.sh
