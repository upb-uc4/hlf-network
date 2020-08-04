# Kubernetes Hyperledger Config

![CI](https://github.com/upb-uc4/hlf-network/workflows/CI/badge.svg?branch=develop)

## Introduction

This repository contains scripts and configuration files for a basic Hyperledger Fabric network running on minikube. The initial topology is based on the [fabric ca operations guide (release 1.4)](
https://hyperledger-fabric-ca.readthedocs.io/en/latest/operations_guide.html). 

## Network

The initial topology of the operations guide implements the most interesting use cases of hyperledger fabric besides multiple orderers.
![Network Topology](https://hyperledger-fabric-ca.readthedocs.io/en/latest/_images/network_topology.png)
There are three organizations, one providing the orderer service and two hosting two peers each on a shared channel. We deploy an external TLS CA which provides TLS certificates for all containers.
We freshly generate and distribute all certificates for this.

## Setup

You need to install [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) and [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/). If you are new to kubernetes, we suggest the [interactive tutorials](https://kubernetes.io/docs/tutorials/) provided by kubernetes.

## Guide to the Kubernetes Hyperledger Config

wo welche Skripte \
wo welche Zertifikate, warum eigene msp Ordner, warum Kopieren von Zertifikaten (TLS signing certificates, i.e. signcerts, need to be available on each host which intends to run commands against the TLS CA.)? \
was liegt in scripts\
wo welche config files, there are config files for setting up the CAs for each organization and each peer, Each component consists of one config file for the Kubernetes deployment and one for a Kubernetes service. \


## Our Conceptual Deployment Steps

### CAs
We make use of one root TLS CA which provides our organizations with TLS certificates ensuring secure communication.
An admin has to be enrolled and then identities can be registered \
The signing certificates are used to validate certificates.

### Organizations
The Orderer is implemented by being an organization in the network. Its task is to...\ 
Each organization is set up by enrolling a CA admin and registering identities for their members (peers, admin, user). For setting up peers for the organization, peers need to be enrolled and launched. 

### Orderer
create Genesis block 
Wie wir an die Certificates kommen: Unlike explained in the guide referenced above, we...\
Launching the orderer service allows us to...\

### CLI containers
One CLI for each organization.
Creating a channel and letting peers join is done using these CLIs. 

### Install and Invoke Chaincode
All chaincode configurations and commands are based on the newest available releases, i.e., verion 2.x. See this [article for a reference about the differences between Fabric's chaincode container versions](https://medium.com/@kctheservant/chaincode-container-comparison-between-fabric-v1-4-and-v2-0-50a835aaad6a). 
new chaincode lifecycle commands, process consists in Packaging, Installing, Approving and Committing before the chaincode can finally be invoked. The advantage is that each organization has an impact on... \
These commands are being used:\




## Starting the network

To start the network execute `./startNetwork.sh`. Check the status of your network with `kubectl get all -n hlf-production-network` or in the browser dashboard `minikube dashboard`. The latter allows you to easily log into the pods and read the logs (make sure you select the hlf-production-network workspace). You can delete everything and restart the network using `./restartNetwork`. Use the `-d` flag to activate debug output.

To reset the network, execute `./deleteNetwork.sh`. You can stop minicube with `minikube stop` if desired.

## Development 

We utilize environment variables to make our configurations flexible while keeping the needed tools at a bare minimum. When we start the network, we copy all configuration files from the templates folder to the `.k8s` folder where we replace placeholders (environment variables) by the values set in `settings.sh`. In addition to this, the minikube ip is read and set by the `applyConfig.sh` script which handles this process. If desired, users can overwrite these settings in a `user-settings.sh` script that is ignored by git.

The startNetwork script uses these filled configuration files and deploys the corresponding entities to kubernetes. The script follows the operations guide. We mount the temporary  `tmp` folder to kubernetes which allows us to easily copy certificates and provide resources to the containers.

We deploy all kubernetes components to the same hlf-production-network namespace which allows use to easily delete and restart the network from scratch.

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