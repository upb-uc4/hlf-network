source ./env.sh

mkdir $TMP_FOLDER/hyperledger/chaincode
wget -c https://github.com/hyperledger/fabric-samples/archive/v2.1.1.tar.gz -O - | tar -xz -C $TMP_FOLDER/hyperledger/chaincode --strip-components=1


get_pods() {
  #1 - app name
  kubectl get pods -l app=$1 --field-selector status.phase=Running -n hlf-production-network --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | head -n 1
}

CLI=$(get_pods "cli-org1")


kubectl exec -n hlf-production-network $CLI -i -- sh < scripts/installChaincodeOrg1.sh
