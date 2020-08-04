get_pods() {
  #1 - app name
  kubectl get pods -l app=$1 --field-selector status.phase=Running -n hlf-production-network --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | head -n 1
}

# Exit on errors
set -e

source ./env.sh

echo "Download chaincode"
mkdir -p $TMP_FOLDER/hyperledger/chaincode
wget -c https://github.com/upb-uc4/University-Credits-4.0/archive/v0.4.3.tar.gz -O - | tar -xz -C $TMP_FOLDER/hyperledger/chaincode --strip-components=1

echo "Build chaincode using gradle"
pushd $TMP_FOLDER/hyperledger/chaincode/product_code/hyperledger/chaincode
./gradlew installDist
popd

echo "Package chaincode on CLI1"
kubectl exec -n hlf-production-network $(get_pods "cli-org1") -i -- sh < scripts/packageChaincode.sh

echo "Install chaincode on Org1 Peers"
kubectl exec -n hlf-production-network $(get_pods "cli-org1") -i -- sh < scripts/installChaincodeOrg1.sh

echo "Install chaincode on Org2 Peers"
kubectl exec -n hlf-production-network $(get_pods "cli-org2") -i -- sh < scripts/installChaincodeOrg2.sh


# Use CLI shell to create channel
source ./settings.sh

echo "Approve chaincode on Org1"
envsubst '${PEERS_TLSCACERTS}' <scripts/approveChaincodeOrg1.sh>$TMP_FOLDER/.approveChaincodeOrg1.sh
kubectl exec -n hlf-production-network $(get_pods "cli-org1") -i -- sh < $TMP_FOLDER/.approveChaincodeOrg1.sh
rm $TMP_FOLDER/.approveChaincodeOrg1.sh

echo "Approve chaincode on Org2"
envsubst '${PEERS_TLSCACERTS}' <scripts/approveChaincodeOrg2.sh>$TMP_FOLDER/.approveChaincodeOrg2.sh
kubectl exec -n hlf-production-network $(get_pods "cli-org2") -i -- sh < $TMP_FOLDER/.approveChaincodeOrg2.sh
rm $TMP_FOLDER/.approveChaincodeOrg2.sh

echo "Check Commit Readiness for channel chaincode"
kubectl exec -n hlf-production-network $(get_pods "cli-org1") -i -- sh < scripts/checkCommitReadiness.sh

echo "Commit chaincode"
envsubst <scripts/commitChaincode.sh>$TMP_FOLDER/.commitChaincode.sh
kubectl exec -n hlf-production-network $(get_pods "cli-org1") -i -- sh < $TMP_FOLDER/.commitChaincode.sh
rm $TMP_FOLDER/.commitChaincode.sh
