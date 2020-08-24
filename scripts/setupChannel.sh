source ./util.sh

sep
echo "Creating channel using CLI1 on Org1 Peer1"
sep

CLI1=$(get_pods "cli-org1")

# Use CLI shell to create channel
source ./settings.sh
envsubst <scripts/createChannel.sh>$TMP_FOLDER/.createChannel.sh

kubectl exec -n hlf-production-network $CLI1 -i -- sh < $TMP_FOLDER/.createChannel.sh
rm $TMP_FOLDER/.createChannel.sh

# Copy mychannel.block from peer1-org1 to peer1-org2
cp $TMP_FOLDER/hyperledger/org1/peer1/assets/mychannel.block $TMP_FOLDER/hyperledger/org2/peer1/assets/mychannel.block

sep
echo "Joining channel using CLI1 on Org1 Peer1 and Peer2"
sep

kubectl exec -n hlf-production-network $CLI1 -i -- sh < scripts/joinChannelOrg1.sh

sep
echo "Joining channel using CLI2 on Org2 Peer1"
sep

CLI2=$(get_pods "cli-org2")

kubectl exec -n hlf-production-network $CLI2 -i -- sh < scripts/joinChannelOrg2.sh