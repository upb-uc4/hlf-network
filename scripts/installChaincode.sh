#!/bin/bash

source ./scripts/util.sh

# Exit on errors
set -e

# Set default branch
export BRANCH_TAG="develop"

print_usage() {
  printf "Usage: ./installChaincode.sh -b [branch or tag]\n"
  printf "Use -b to specify the branch or tag to use (default is develop)\n"
}


while getopts 'b:' flag; do
  case "${flag}" in
    b) BRANCH_TAG="${OPTARG}"
       printf "Branch / Tag: %s selected\n" "$BRANCH_TAG" ;;
    ?) print_usage
       exit 1 ;;
  esac
done

source ./scripts/env.sh

echo "Download chaincode"
mkdir -p $HL_MOUNT/uc4
wget -c https://github.com/upb-uc4/hlf-chaincode/archive/"$BRANCH_TAG".tar.gz -O - | tar -xz -C $HL_MOUNT/uc4 --strip-components=1

echo "Build chaincode using gradle"
pushd $HL_MOUNT/uc4/chaincode
./gradlew installDist
popd

echo "Package chaincode on CLI1"
kubectl exec -n hlf $(get_pods "cli-org1") -i -- sh < scripts/installChaincode/packageChaincode.sh

echo "Install chaincode on Org1 Peers"
kubectl exec -n hlf $(get_pods "cli-org1") -i -- sh < scripts/installChaincode/installChaincodeOrg1.sh

echo "Install chaincode on Org2 Peers"
kubectl exec -n hlf $(get_pods "cli-org2") -i -- sh < scripts/installChaincode/installChaincodeOrg2.sh

echo "Approve chaincode on Org1"
kubectl exec -n hlf $(get_pods "cli-org1") -i -- sh < scripts/installChaincode/approveChaincodeOrg1.sh

echo "Approve chaincode on Org2"
kubectl exec -n hlf $(get_pods "cli-org2") -i -- sh < scripts/installChaincode/approveChaincodeOrg2.sh

echo "Check Commit Readiness for channel chaincode"
kubectl exec -n hlf $(get_pods "cli-org1") -i -- sh < scripts/installChaincode/checkCommitReadiness.sh

echo "Commit chaincode"
kubectl exec -n hlf $(get_pods "cli-org1") -i -- sh < scripts/installChaincode/commitChaincode.sh
