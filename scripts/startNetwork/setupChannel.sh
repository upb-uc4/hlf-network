#!/bin/bash

source ./scripts/util.sh

header "Setting up channel using CLI1 on Org1 Peer1"

CLI1=$(get_pods "cli-org1")

# Use CLI shell to create channel

kubectl exec -n hlf $CLI1 -i -- sh < scripts/startNetwork/setupChannel/createChannel.sh

# Copy mychannel.block from peer1-org1 to peer1-org2
cp $HL_MOUNT/org1/peer1/assets/mychannel.block $HL_MOUNT/org2/peer1/assets/mychannel.block

sep

echo "Joining channel using CLI1 on Org1 Peer1 and Peer2"
kubectl exec -n hlf $CLI1 -i -- sh < scripts/startNetwork/setupChannel/joinChannelOrg1.sh

sep

echo "Joining channel using CLI2 on Org2 Peer1"
CLI2=$(get_pods "cli-org2")
kubectl exec -n hlf $CLI2 -i -- sh < scripts/startNetwork/setupChannel/joinChannelOrg2.sh