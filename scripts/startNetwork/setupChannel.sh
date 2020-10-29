#!/bin/bash

source ./scripts/util.sh

header "Channel Setup"

msg "Creating channel via cli-org1"
CLI1=$(get_pods "cli-org1")
kubectl exec -n hlf $CLI1 -i -- sh < scripts/startNetwork/setupChannel/createChannel.sh

msg "Joining channel with peer1-org1 and peer2-org1"
kubectl exec -n hlf $CLI1 -i -- sh < scripts/startNetwork/setupChannel/joinChannelOrg1.sh

msg "Joining channel with peer1-org2 and peer2-org2"
CLI2=$(get_pods "cli-org2")
kubectl exec -n hlf $CLI2 -i -- sh < scripts/startNetwork/setupChannel/joinChannelOrg2.sh
