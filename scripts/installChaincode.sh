#!/bin/bash

source ./scripts/util.sh

# Exit on errors
set -e

# Set default branch
export CHAINCODE_VERSION_PATH="latest/download"

print_usage() {
  printf "Usage: ./installChaincode.sh -b [version|release]\n"
  printf "Use -b to specify the version|release to use (default is latest)\n"
}


while getopts 'b:' flag; do
  case "${flag}" in
    b) CHAINCODE_VERSION_PATH="download/${OPTARG}" ;;
    ?) print_usage
       exit 1 ;;
  esac
done

source ./scripts/env.sh

header "Downloading chaincode"
msg "Downloading from target $CHAINCODE_VERSION_PATH"
mkdir -p $HL_MOUNT/uc4/assets
mkdir -p $HL_MOUNT/uc4/UC4-chaincode
wget -q -c https://github.com/upb-uc4/hlf-chaincode/releases/"$CHAINCODE_VERSION_PATH"/UC4-chaincode.tar.gz -O - | tar -xz -C $HL_MOUNT/uc4/UC4-chaincode
msg "Download assets"
wget -q -c https://github.com/upb-uc4/hlf-chaincode/releases/"$CHAINCODE_VERSION_PATH"/collections_config.json -O "$HL_MOUNT/uc4/assets/collections_config.json"

jarPath=$HL_MOUNT/uc4/UC4-chaincode/UC4-chaincode/UC4-chaincode*.jar
unzip -q -c $jarPath META-INF/MANIFEST.MF | grep 'Implementation-Version' | cut -d ':' -f2>>$HL_MOUNT/uc4/assets/testversion.txt
# print
chaincode_version=cat /tmp/hyperledger/chaincode/assets/testversion.txt
msg "CHAINCODE VERSION: $chaincode_version"

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
