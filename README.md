# Kubernetes Hyperledger Config

![CI](https://github.com/upb-uc4/hlf-network/workflows/CI/badge.svg?branch=develop)

## Introduction

This repository contains scripts and configuration files for a basic Hyperledger Fabric network running on minikube. The initial topology is based on the [fabric ca operations guide (release 1.4)](
https://hyperledger-fabric-ca.readthedocs.io/en/latest/operations_guide.html). 

## Setup

You need to install [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) and [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/). If you are new to kubernetes, we suggest the [interactive tutorials](https://kubernetes.io/docs/tutorials/) provided by kubernetes.

## Starting the network

To start the network execute `./startNetwork.sh`. Check the status of your network with `kubectl get all -n hlf-production-network` or in the browser dashboard `minikube dashboard`. The latter allows you to easily log into the pods and read the logs (make sure you select the hlf-production-network workspace). You can delete everything and restart the network using `./restartNetwork`. Use the `-d` flag to activate debug output.

Currently, in order to install chaincode on the channel, execute 

To reset the network, execute `./deleteNetwork.sh`. You can stop minicube with `minikube stop` if desired.


## Network

The initial topology of the operations guide implements the most interesting use cases of hyperledger fabric besides multiple orderers.
![Network Topology](https://hyperledger-fabric-ca.readthedocs.io/en/latest/_images/network_topology.png)
There are three organizations, one providing the orderer service and two hosting two peers each on a shared channel. We deploy an external TLS CA which provides TLS certificates for all containers.
We freshly generate and distribute all certificates for this.

## Our Conceptual Deployment Steps

Links (Discord)
https://hyperledger-fabric.readthedocs.io/en/release-2.1/deployment_guide_overview.html

### CAs
We make use of one root TLS CA which provides our organizations with TLS certificates ensuring secure communication.
An admin has to be enrolled and then identities can be registered \
The signing certificates are used to validate certificates.

### Organizations
The Orderer is implemented by being an organization in the network. Its task is to...\ 
Each organization is set up by enrolling a CA admin and registering identities for their members (peers, admin, user). For setting up peers for the organization, peers need to be enrolled and launched. 

### Orderer
The orderer is in charge of... The orderer's identity needs to be enrolled with a CA in order to get/ generate its local MSP (artifacts).\
The orderer requires a genesis block to bootstrap itself(?). The genesis block provides configurations for a channel, which are specified in the configtx file. More information on the channel configuration file can be found in the [Hyperledger Fabric documentation](https://hyperledger-fabric.readthedocs.io/en/release-1.4/configtx.html?channel-configuration-configtx). \
The commands `/configtxgen -profile OrgsOrdererGenesis -outputBlock $TMP_FOLDER/hyperledger/org0/orderer/genesis.block -channelID syschannel` and `./configtxgen -profile OrgsChannel -outputCreateChannelTx $TMP_FOLDER/hyperledger/org0/orderer/channel.tx -channelID mychannel` generate the `genesis.block` and the `channel.tx` files. The `channel.tx` file will be used to create the channel. \
TODO: Do we use the commands for gathering certificates?

Wie wir an die Certificates kommen: Unlike explained in the guide referenced above, we...\
Launching the orderer service allows us to...\

### CLIs and channel creation
CLI containers are required to enable communication with peers.
We use one CLI container for each organization. We start the CLI containers in the same host machine as peer1 for each org(?).
Using these CLIs, we can create a channel and let peers join it. For this, the following commands can be issued in the CLIs:
`kubectl exec -n hlf-production-network $CLI1 -i -- sh < $TMP_FOLDER/.createChannel.sh` 
and `channel create \
         -c mychannel \
         -f /tmp/hyperledger/org1/peer1/assets/channel.tx \
         -o orderer-org0:7050 \
         --outputBlock /tmp/hyperledger/org1/peer1/assets/mychannel.block \
         --tls \
         --cafile /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/${PEERS_TLSCACERTS}`
The first command executes the CLI and the second command generates the mychannel.block on peer1 which can be used by other peers in the network to join the channel.
For joining the channel we issue(?) the commands `peer channel join -b /tmp/hyperledger/org1/peer1/assets/mychannel.block` for the respective peers.


### Install and Invoke Chaincode
All chaincode configurations and commands are based on the newest available releases, i.e., verion 2.x. See this [article for a reference about the differences between Fabric's chaincode container versions](https://medium.com/@kctheservant/chaincode-container-comparison-between-fabric-v1-4-and-v2-0-50a835aaad6a). 
new chaincode lifecycle commands, process consists in Packaging, Installing, Approving and Committing before the chaincode can finally be invoked. The advantage is that each organization has an impact on... \
These commands are being used:\




## Guide to the Kubernetes Hyperledger Config

wo welche Skripte \
wo welche Zertifikate, warum eigene msp Ordner, warum Kopieren von Zertifikaten (TLS signing certificates, i.e. signcerts, need to be available on each host which intends to run commands against the TLS CA.)? \
was liegt in scripts\
wo welche config files, there are config files for setting up the CAs for each organization and each peer, Each component consists of one config file for the Kubernetes deployment and one for a Kubernetes service. \
(Enrollment) MSP directory: ca contains the enrollment certificate, tls-ca contains the TLS certificate, admincerts folder contains certificates of the administrators 

directory structure/ tree:
```
project
+-- congif.yaml
+-- scripts
|   +-- debug.sh
+-- delete
```


## Development 

We utilize environment variables to make our configurations flexible while keeping the needed tools at a bare minimum. When we start the network, we copy all configuration files from the templates folder to the `.k8s` folder where we replace placeholders (environment variables) by the values set in `settings.sh`. In addition to this, the minikube ip is read and set by the `applyConfig.sh` script which handles this process. If desired, users can overwrite these settings in a `user-settings.sh` script that is ignored by git.

The startNetwork script uses these filled configuration files and deploys the corresponding entities to kubernetes. The script follows the operations guide. We mount the temporary  `tmp` folder to kubernetes which allows us to easily copy certificates and provide resources to the containers.

We deploy all kubernetes components to the same hlf-production-network namespace which allows use to easily delete and restart the network from scratch.

use of namespace (?)

Issue with timeouts, integrated wait commands (?)

### Working with Pods

List the name of all pods: `kubectl get pods -n hlf-production-network`.

Get shell on CLI container `kubectl exec -n hlf-production-network {CLI-POD} -it -- sh`.

Get logs of container `kubectl logs {POD} -n hlf-production-network`.

You can omit the namespace parameter if you set the context of kubectl `kubectl config set-context --current --namespace=hlf-production-network`.

## Versions 

We use the release 2.2 for all hyperledger fabric components besides the CA server and client where the latest release is 1.4. The binary files are compiled from these releases and might be incompatible to other versions.

## License

Our source code files are made available under the Apache License, Version 2.0 (Apache-2.0), located in the [LICENSE](LICENSE) file.

The included binaries are built from
 - fabric-ca-client [Hyperledger Fabric CA, Release 1.4.7](https://github.com/hyperledger/fabric-ca)
 - configtxgen [Hyperledger Fabric, Release 2.2](https://github.com/hyperledger/fabric)

both published under the Apache-2.0 license.