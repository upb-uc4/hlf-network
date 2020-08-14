get_pods() {
  #1 - app name
  kubectl get pods -l app=$1 --field-selector status.phase=Running -n hlf-production-network --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | head -n 1
}

# Exit on errors
set -e

# Set default branch
export BRANCH_TAG=develop

if [ -z "$1" ]
then
  echo "Installing latest chaincode from develop."
  echo "Use './installChaincode.sh [branch|tag]' to specify another branch or tag."
else
  echo "Using branch / tag: $1"
  export BRANCH_TAG=$1
fi
echo ""

source ./env.sh

echo "Download chaincode"
mkdir -p $TMP_FOLDER/hyperledger/uc4
wget -c https://github.com/upb-uc4/hyperledger_chaincode/archive/"$BRANCH_TAG".tar.gz -O - | tar -xz -C $TMP_FOLDER/hyperledger/uc4 --strip-components=1

echo "Build chaincode using gradle"
pushd $TMP_FOLDER/hyperledger/uc4/chaincode
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
