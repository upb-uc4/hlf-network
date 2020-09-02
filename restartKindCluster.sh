kind delete clusters kind
sudo rm -rf /data
sudo mkdir -p /data/uc4/development/hyperledger
sudo chmod -R 777 /data/uc4
kind create cluster --config kind.yaml
./startNetwork.sh
./installChaincode.sh