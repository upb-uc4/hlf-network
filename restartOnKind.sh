#!/bin/bash

kind delete cluster
sudo rm -rf /data/development/hyperledger/
./createKindCluster.sh
./deploy.sh