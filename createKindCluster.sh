# This script is for development only and allows easily starting and restarting a kubernetes cluster on KinD
# For production, deploy the cluster first and use the deploy script to start the network

set +e
kind delete clusters kind
sudo rm -rf /data/development

set -e
sudo mkdir -p /data/development/hyperledger
sudo chmod -R 777 /data/development

kind create cluster --config kind.yaml
