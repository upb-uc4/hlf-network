# Exit on errors
set -e

create-channel() {
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
}


# Debug commands using -d flag
export DEBUG=""
if [[ $1 == "-d" ]]; then
  echo "Debug mode activated"
  export DEBUG="-d"
fi

# Set environment variables
source ./env.sh
source ./util.sh

# Use configuration file to generate kubernetes setup from the template
# TODO: Avoid necessity for configuring IPs by making use of kubernetes' internal DNS
./applyConfig.sh

mkdir -p $TMP_FOLDER/hyperledger

# Mount tmp folder
# TODO: Replace local mounts with PVCs
small_sep
echo "Mounting tmp folder to minikube"
minikube mount $TMP_FOLDER/hyperledger:/hyperledger &
sleep 3

small_sep
kubectl create -f $K8S/namespace.yaml

source ./scripts/setupTlsCa.sh
source ./scripts/setupOrdererOrgCa.sh
source ./scripts/setupOrg1Ca.sh
source ./scripts/setupOrg2Ca.sh
source ./scripts/enrollPeersOrg1.sh
source ./scripts/enrollPeersOrg2.sh
source ./scripts/startPeers.sh
source ./scripts/setupOrderer.sh
source ./scripts/startClis.sh
source ./scripts/setupDind.sh
create-channel


# For scala api
rm -rf /tmp/hyperledger/
mkdir -p /tmp/hyperledger/
mkdir -p /tmp/hyperledger/org0
mkdir -p /tmp/hyperledger/org1
mkdir -p /tmp/hyperledger/org2
cp $TMP_FOLDER/ca-cert.pem /tmp/hyperledger/
cp -a $TMP_FOLDER/hyperledger/org0/msp /tmp/hyperledger/org0
cp -a $TMP_FOLDER/hyperledger/org1/msp /tmp/hyperledger/org1
cp -a $TMP_FOLDER/hyperledger/org2/msp /tmp/hyperledger/org2

sep

echo -e "Done. Execute \e[2mminikube dashboard\e[22m to open the dashboard or run \e[2m./deleteNetwork.sh\e[22m to shutdown and delete the network."
