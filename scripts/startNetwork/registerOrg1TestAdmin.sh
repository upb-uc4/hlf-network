#!/bin/bash

source ./scripts/util.sh
source ./scripts/env.sh

header "Registering test admin"

kubectl exec -n hlf $(get_pods "rca-org1") -i -- bash /tmp/hyperledger/scripts/startNetwork/registerUsers/registerTestAdmin.sh
