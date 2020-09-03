source env.sh

set +e
kind delete clusters kind
sudo rm -rf $K8S_MOUNT

set -e
sudo mkdir -p $HL_MOUNT
sudo chmod -R 777 $K8S_MOUNT

./scripts/setMountFolder.sh
kind create cluster --config kind.yaml

./startNetwork.sh
./installChaincode.sh