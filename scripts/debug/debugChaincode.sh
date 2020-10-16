#!/bin/bash

source ./scripts/util.sh

# Exit on errors
set -e

source ./env.sh

kubectl exec -n hlf $(get_pods "cli-org1") -i -- sh < scripts/debug/debugChaincode/queryInstalledOrg1.sh
kubectl exec -n hlf $(get_pods "cli-org2") -i -- sh < scripts/debug/debugChaincode/queryInstalledOrg2.sh
kubectl exec -n hlf $(get_pods "cli-org1") -i -- sh < scripts/debug/debugChaincode/queryCommited.sh
