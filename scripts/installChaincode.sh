#!/bin/bash

source ./scripts/util.sh

# Exit on errors
set -e

# Set default branch
export CHAINCODE_VERSION="v0.12.2"

print_usage() {
  printf "Usage: ./installChaincode.sh -b [branch or tag]\n"
  printf "Use -b to specify the branch or tag to use (default is develop)\n"
}


while getopts 'b:' flag; do
  case "${flag}" in
    b) CHAINCODE_VERSION="${OPTARG}" ;;
    ?) print_usage
       exit 1 ;;
  esac
done

source ./scripts/env.sh

header "Downloading chaincode"
msg "Downloading branch or tag $BRANCH_TAG"
mkdir -p $HL_MOUNT/uc4/assets
mkdir -p $HL_MOUNT/uc4/UC4-chaincode
wget -c https://github.com/upb-uc4/hlf-chaincode/releases/download/"$CHAINCODE_VERSION"/UC4-chaincode.tar.gz -O - | tar -xz -C $HL_MOUNT/uc4/UC4-chaincode
msg "Download assets"
wget -c https://github.com/upb-uc4/hlf-chaincode/releases/download/"$CHAINCODE_VERSION"/collections_config.json -O "$HL_MOUNT/uc4/assets/collections_config.json"

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
