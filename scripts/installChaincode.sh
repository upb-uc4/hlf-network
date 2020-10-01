#!/bin/bash

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
mkdir -p $HL_MOUNT/uc4
wget -c https://github.com/upb-uc4/hlf-chaincode/archive/"$BRANCH_TAG".tar.gz -O - | tar -xz -C $HL_MOUNT/uc4 --strip-components=1

echo "Build chaincode using gradle"
pushd $HL_MOUNT/uc4/chaincode
./gradlew installDist
popd

echo "Package chaincode on CLI1"
kubectl exec -n hlf-production-network $(get_pods "cli-org1") -i -- sh < scripts/packageChaincode.sh

echo "Install chaincode on Org1 Peers"
kubectl exec -n hlf-production-network $(get_pods "cli-org1") -i -- sh < scripts/installChaincodeOrg1.sh

echo "Install chaincode on Org2 Peers"
kubectl exec -n hlf-production-network $(get_pods "cli-org2") -i -- sh < scripts/installChaincodeOrg2.sh

echo "Approve chaincode on Org1"
kubectl exec -n hlf-production-network $(get_pods "cli-org1") -i -- sh < scripts/approveChaincodeOrg1.sh

echo "Approve chaincode on Org2"
kubectl exec -n hlf-production-network $(get_pods "cli-org2") -i -- sh < scripts/approveChaincodeOrg2.sh

echo "Check Commit Readiness for channel chaincode"
kubectl exec -n hlf-production-network $(get_pods "cli-org1") -i -- sh < scripts/checkCommitReadiness.sh

echo "Commit chaincode"
kubectl exec -n hlf-production-network $(get_pods "cli-org1") -i -- sh < scripts/commitChaincode.sh