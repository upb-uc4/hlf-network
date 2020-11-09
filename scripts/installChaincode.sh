#!/bin/bash

source ./scripts/util.sh

# Exit on errors
set -e

# Set default branch
export BRANCH_TAG="feature/publish_to_maven"

print_usage() {
  printf "Usage: ./installChaincode.sh -b [branch or tag]\n"
  printf "Use -b to specify the branch or tag to use (default is develop)\n"
}


while getopts 'b:' flag; do
  case "${flag}" in
    b) BRANCH_TAG="${OPTARG}" ;;
    ?) print_usage
       exit 1 ;;
  esac
done

source ./scripts/env.sh

header "Downloading chaincode"
msg "Downloading branch or tag $BRANCH_TAG"
mkdir -p $HL_MOUNT/uc4
wget -c https://github.com/upb-uc4/hlf-chaincode/archive/"$BRANCH_TAG" -O - | tar -xz -C $HL_MOUNT/uc4 --strip-components=1

header "Build"
pushd $HL_MOUNT/uc4/UC4-chaincode
msg "Building chaincode using gradle"
./gradlew installDist
popd

header "Installation"
msg "Packaging chaincode on CLI1"
kubectl exec -n hlf $(get_pods "cli-org1") -i -- sh < scripts/installChaincode/packageChaincode.sh

msg "Installing chaincode on Org1 Peers"
kubectl exec -n hlf $(get_pods "cli-org1") -i -- sh < scripts/installChaincode/installChaincodeOrg1.sh

msg "Installing chaincode on Org2 Peers"
kubectl exec -n hlf $(get_pods "cli-org2") -i -- sh < scripts/installChaincode/installChaincodeOrg2.sh

header "Approval"
msg "Approve chaincode on Org1"
kubectl exec -n hlf $(get_pods "cli-org1") -i -- sh < scripts/installChaincode/approveChaincodeOrg1.sh

msg "Approve chaincode on Org2"
kubectl exec -n hlf $(get_pods "cli-org2") -i -- sh < scripts/installChaincode/approveChaincodeOrg2.sh

msg "Commit"
header "Check Commit Readiness for channel chaincode"
kubectl exec -n hlf $(get_pods "cli-org1") -i -- sh < scripts/installChaincode/checkCommitReadiness.sh

msg "Commit chaincode"
kubectl exec -n hlf $(get_pods "cli-org1") -i -- sh < scripts/installChaincode/commitChaincode.sh
