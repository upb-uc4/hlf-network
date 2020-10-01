# Hyperledger Fabric Network on Kubernetes

![CI](https://github.com/upb-uc4/hlf-network/workflows/CI/badge.svg?branch=develop)

## Introduction

This repository contains scripts and configuration files for a basic Hyperledger Fabric network running on Kubernetes. The topology is based on the [Hyperledger Fabric CA operations guide (release 1.4)](
https://hyperledger-fabric-ca.readthedocs.io/en/latest/operations_guide.html). 

## Table of Contents

- [Hyperledger Fabric Network on Kubernetes](#hyperledger-fabric-network-on-kubernetes)
  * [Introduction](#introduction)
  * [Table of Contents](#table-of-contents)
  * [Getting Started](#getting-started)
    + [Prerequisites on Kubernetes in Docker (KinD)](#prerequisites-on-kubernetes-in-docker--kind-)
    + [Starting the Network](#starting-the-network)
  * [Network Topology](#network-topology)
  * [Deployment Steps](#deployment-steps)
    + [TLS-CA](#tls-ca)
    + [Organizations and Enrollment-CAs](#organizations-and-enrollment-cas)
    + [Orderer](#orderer)
    + [CLIs and Channel Creation](#clis-and-channel-creation)
    + [Install and Invoke Chaincode](#install-and-invoke-chaincode)
    + [Further Readings](#further-readings)
  * [For Developers](#for-developers)
    + [Project Structure](#project-structure)
      - [Main Scripts](#main-scripts)
      - [MSP Directories](#msp-directories)
    + [Implementation Details](#implementation-details)
    + [Using kubectl](#using-kubectl)
    + [Debugging](#debugging)
  * [Changelog](#changelog)
  * [Versions](#versions)
  * [License](#license)
  * [Troubleshooting](#troubleshooting)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>
  
## Getting Started

For setting up our project, you need to install [KinD](https://kind.sigs.k8s.io/docs/user/quick-start/) and [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/). If you are new to Kubernetes, we suggest the [interactive tutorials](https://kubernetes.io/docs/tutorials/) provided by Kubernetes. 

To start a cluster for development, run ```./restartKindCluster.sh```.

To deploy the network, execute ```./deploy.sh [chaincode-branch]```, if no branch is given the current develop chaincode in installed.

To delete the cluster, run ```kind delete cluster```, to remove all files ```sudo rm -rf /data/development/hyperledger/```.

Check the status of your network with `kubectl get all -n hlf-production-network` or in the browser dashboard by typing `minikube dashboard`. 
The latter allows you to easily log into the pods and read the logs (make sure you select the hlf-production-network workspace in the dashboard GUI on the left handside). Use the `-d` flag to activate debug output.

## Network Topology

The initial network topology suggested by the [operations guide](https://hyperledger-fabric-ca.readthedocs.io/en/latest/operations_guide.html) implements the most interesting use cases of hyperledger fabric. For using multiple orderers later, we would have to use the [raft protocol](https://raft.github.io/) since kafka is deprecated.

The network consists of three organizations, one providing the orderer service and two hosting two peers each communicating on a shared channel. 
We deploy an external TLS CA which provides TLS certificates for all containers.
We freshly generate and distribute all certificates for this.
The following figure visualizes the implemented network.
![Network Topology](https://hyperledger-fabric-ca.readthedocs.io/en/latest/_images/network_topology.png)
Note: Network Topology. Reprinted from the [Fabric CA operations guide](https://hyperledger-fabric-ca.readthedocs.io/en/latest/operations_guide.html).
<!---TODO: Note or Fig?-->

## Deployment Steps
In this part, we conceptually explain the steps of our deployment and the implemented network entities.

### TLS-CA
We make use of TLS to ensure secure communication with our entities. Therefore, we provide a TLS-CA server that contains our TLS root certificate and provides TLS certificates to our network components. The TLS root certificate needs to be distributed via a secure channel (and added to the client's keystore) such that clients can verify their communication partner's TLS certicicate. 

### Organizations and Enrollment-CAs 
Each organization is set up by enrolling a CA admin and registering identities for their members, including their roles, i.e., peers, admins, users. Peers need to be enrolled by the CA admin of their organization before they are launched.
Membership, roles and privileges within an organization are managed by an enrollment CA server, which issues certificates to members. 

### Orderer
The Orderer is represented by an organization in the network. Its task is to order transactions and group them into a block as well as being in charge of the consortium.
The orderer's identity needs to be enrolled with a CA in order to <!---get/--> generate its local MSP<!---(artifacts)-->.\
The orderer requires a genesis block to launch itself. The genesis block provides configurations for a channel, which are specified in the configtx file. This file also contains all information to generate the genesis block itself. More information on the channel configuration file can be found in the [Hyperledger Fabric documentation](https://hyperledger-fabric.readthedocs.io/en/release-1.4/configtx.html?channel-configuration-configtx). The commands 
```
/configtxgen -profile OrgsOrdererGenesis -outputBlock $HL_MOUNT/org0/orderer/genesis.block -channelID syschannel
```
and

```
 ./configtxgen -profile OrgsChannel -outputCreateChannelTx $HL_MOUNT/org0/orderer/channel.tx -channelID mychannel
``` 
 
generate the `genesis.block` and the `channel.tx` files. The `channel.tx` file will be used to create the channel.

<!---Wie wir an die Certificates kommen: Unlike explained in the guide referenced above, we...\
Launching the orderer service allows us to...\-->

### CLIs and Channel Creation
CLI containers are required to administrate the network and enable communication with the peers.
Therefore, we use one CLI container for each organization that has the respective admin rights.\
The CLI containers are started in the same host machine as peer1 for each organization.
Using these CLIs, we can create a channel and let peers join it. For this, the following command can be used to execute shell scripts in the CLIs:
```
kubectl exec -n hlf-production-network $CLI1 -i -- sh < $someScript.sh
``` 
This command generates the mychannel.block on peer1 which can be used by other peers in the network to join the channel:
```
channel create \
         -c mychannel \
         -f /tmp/hyperledger/org1/peer1/assets/channel.tx \
         -o orderer-org0:7050 \
         --outputBlock /tmp/hyperledger/org1/peer1/assets/mychannel.block \
         --tls \
         --cafile /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-ca-tls-hlf-production-network-7052.pem
```
For joining the channel we use the command
```
peer channel join -b /tmp/hyperledger/org1/peer1/assets/mychannel.block
``` 
for the respective peers.

### Install and Invoke Chaincode
Chaincode in Hyperledger Fabric represents the smart contracts or business logic for an application.
All our chaincode configurations and commands are based on the newest available releases, i.e., version 2.x, whose chaincode deployment concept differs a bit from the former fabric version 1.x. See this [article](https://medium.com/@kctheservant/chaincode-container-comparison-between-fabric-v1-4-and-v2-0-50a835aaad6a) as a reference to the differences between Fabric's chaincode container versions.   
<!--- The chaincode is executed in specific chaincode containers.-->
This new chaincode deployment concept is called `chaincode lifecycle` and it handles the complete management of chaincode.
The advantage of this new concept is that multiple endorsing peers can be involved in the decision on how a chaincode is operated before its usage on the channel. The endorsement policy for this process is prescribed in the configtx configuration file.
The chaincode lifecycle includes the following deployment steps: 
1. Build the chaincode using gradle.
2. The chaincode is packaged in the CLI container, which directly builds the chaincode container image.
3. The chaincode is installed in this format on selected peers. (This installation process will take a few minutes since a java environment for the chaincode is downloaded and each peer builds its own chaincode docker image.)
4. The instantiating process of version v1.4 is replaced by an approvement given by the peers for their organization. 
5. After organizations have approved, the chaincode definition is committed to the channel. 

After this chaincode deployment the chaincode containers are running, hence, the chaincode can be invoked and queried by the peers.
For the chaincode, we currently deploy one explicit container called `dind` (docker in docker) which allows every peer to deploy the chaincode without having access rights to the docker daemon. 

### Further Readings
This guide serves as a starting point. If you are interested in more details, we recommend the following references which were particularly useful for us during development: <!---TODO: check and order-->  

* [Deploying a Production Network](https://hyperledger-fabric.readthedocs.io/en/release-2.2/deployment_guide_overview.html)
* [Fabric CA Operations Guide](https://hyperledger-fabric-ca.readthedocs.io/en/latest/operations_guide.html)
* [CA Deployment Steps](https://hyperledger-fabric-ca.readthedocs.io/en/latest/deployguide/cadeploy.html) 
* [Channel Configuration](https://hyperledger-fabric.readthedocs.io/en/release-2.2/configtx.html?channel-configuration-configtx)
* [Chaincode Lifecycle](https://hyperledger-fabric.readthedocs.io/en/release-2.2/chaincode_lifecycle.html)


## For Developers 

This section contains useful information for developers who are new to this project.

### Project Structure
<!---TODO: can be improved and extended and maybe separated-->
```
| k8s-templates                     # template definitions of all deployments and services for the network components 
    +-- dind                        # container for the chaincode deployment 
    +-- orderer
    +-- orderer-org-ca
    +-- org1-ca
    +-- org1-peer1
    +-- org1-peer2
    +-- org2-ca 
    +-- org2-peer1
    +-- org2-peer2
    +-- tls-ca
    +-- namespace.yaml
    +-- org1-cli.yaml
    +-- org2-cli.yaml
| scripts
|   +-- debug
        +-- TODO
    +-- installChaincodeOrg1.sh
    +-- installChaincodeOrg2.sh

| tmp                                # temporary files available during network runtime mounting our certificates
    +-- hyperledger
        +-- chaincode
            ...
        +-- dind
        +-- org0
            +-- admin
                +-- msp
                    +-- cacerts
                        +-- 172-17-0-2-30906.pem  
                    +-- keystore       # private key
                    +-- signcerts
                        +-- cert.pem   # certificate after enrollment of Org0's admin
                    +-- user
                +-- fabric-ca-client-config.yaml
            +-- ca
                +-- admin
                    +-- msp
                        +-- cacerts
                            +-- 172-17-0-2-30906.pem
                        +-- keystore    # private key
                        +-- signcerts
                            +-- cert.pem
                        +-- user
                    +-- fabric-ca-client-config.yaml
                +-- crypto
                    +-- msp
                    +-- ca-cert.pem
                    +-- fabric-ca-server-config.yaml
                    +-- tls-cert.pem
            +-- msp
                +-- admincerts
                    +-- admin-org0-cert.pem   # certificate of the Org0's admin identity
                +-- cacerts
                    +-- org0-ca-cert.pem      # trusted root certificate of Org0 (organisation-level)
                +-- tlscacerts
                    +-- tls-ca-cert.pem       # trusted root certificate of the TLS CA
                +-- users
            +-- orderer
                +-- assets
                    +-- ca
                        +-- org0-ca-cert.pem  # trusted root certificate for Org0
                    +-- tls-ca
                        +-- tls-ca-cert.pem   # certificate of the TLS CA
                +-- msp
                    +-- admincerts
                        +-- orderer-admin-cert.pem  # certificate of Org0's admin
                    +-- cacerts
                        +-- 172-17-0-2-30906.pem
                    +-- keystore                    # private key
                    +-- signcerts
                        +-- cert.pem
                    +-- user
                +-- tls-msp
                    +-- cacerts
                    +-- keystore
                        +-- key.pem
                    +-- signcerts
                        +-- cert.pem
                    +-- tlscacerts
                        +-- tls-172-17-0-2-30905.pem
                    +-- user
                +-- channel.tx
                +-- fabric-ca-client-config.yaml
                +-- genesis.block
        +-- org1
            ...
        +-- org2
            ...
        +-- tls-ca
            +-- admin
            +-- crypto
        +-- uc4
    +-- ca-cert.pem                        # the TLS certificate shared by all organizations
| configtx.yaml                            # our channel configuration file 
| deleteNetwork.sh                         # script to delete the network 
| installChaincode.sh                      # script which processes the chaincode lifecycle
| restartNetwork.sh                        # deletes and restarts the network
| settings.sh 
| startNetwork.sh                          # fundamental network deployment script
| testInstalledChaincode.sh                # invokes a chaincode function for testing
```

#### Main Scripts
The most fundamental script is <b>```startNetwork.sh```</b> where the network is deployed by creating and launching respective Deployments and Services in minikube as well as enrolling and registering users which involves the provision of respective certificates for all participating parties.\
We first set up the TLS CA and the CAs for all organizations, respectively. Then we enroll the peers for the organizations Org1 and Org2 and start them by creating deployments in minikube. 
In the next step, we set up the orderer which includes the enrollment of its admin identity, the generation of the genesis block as well as the launch of the deployment in minikube. For the orderer's MSP directory, we create MSP folders locally in order to store the respective certificates of all organizations in this ordering host explicitly. 
Next, the CLIs are created in minikube, one for each organization Org1 and Org2. These can be used in the following to create the channel. \
The file <b>```installChaincode.sh```</b> consists of the logic for installing chaincode on the channel processing all steps of the chaincode lifecycle. 

#### MSP Directories
The MSP directories include the material necessary for enrollment: the `ca` folder contains the enrollment certificate, the `tls-ca` folder contains the TLS certificate, the `admincerts` folder contains certificates of the administrators. 
The folders keystore and signcerts are generated for the entities which sign or endorse transactions. 
The private keys are stored in the folders keystore and are generated during the enrollment with TLS. The folders signcerts store the associated certificates for signing. Hence, these two files belong together since they provide the sensitive signing material.
The structure of the organizations is very similar. Org0 has the extra folder `orderer`, Org1 and Org2 have the files `peer1` and `peer2` instead, each containing an msp folder again, and additional admin certificates. 

<!---More advanced/ longer explanations on specific folders or files may come here?-->
<!---The templating (and the environment variables for the IP addresses) are necessary to set the respective IP addresses on start of the network? It allows more manual configuration depending on the host machine without changing the tracked files.-->

<!---### MSP folder structure-->
<!---TODO: Does the same file structure apply to all organizations? Maybe separate the certificate file structure from the overall file structure.-->
<!---wo welche Zertifikate, warum eigene msp Ordner, warum Kopieren von Zertifikaten (TLS signing certificates, i.e. signcerts, need to be available on each host which intends to run commands against the TLS CA.)?-->

### Implementation Details

The startNetwork script uses these filled configuration files and deploys the corresponding entities to kubernetes. We mount the temporary `/data/uc4/deployment` folder to kubernetes which allows us to easily copy certificates and provide resources to the containers.

We deploy all kubernetes components to the same `hlf-production-network` namespace which separates our components from other components running in Kubernetes and allows us to easily and safely delete and restart the network from scratch.

### Using kubectl

List the name of all pods: `kubectl get pods -n hlf-production-network`.

Get shell on CLI container `kubectl exec -n hlf-production-network {CLI-POD} -it -- sh`.

Get logs of container `kubectl logs {POD} -n hlf-production-network`.

You can omit the namespace parameter, if you set the context of kubectl `kubectl config set-context --current --namespace=hlf-production-network`.

### Debugging

For debugging, we provide a few scripts in the folder scripts/debug. When executing 
```
./podShell.sh deployment-name [container name]
```
in order to run a shell on the specific pod. For viewing the logs of a specific pod, execute 
```
./getLogs.sh deployment-name [container name]
``` 
with the respective deployment name. The optional parameter `container name` is needed, if there are two different containers running on the same pod.

## Changelog

To get an overview of our developmental process, we tagged our releases and added a [Changelog](https://github.com/upb-uc4/hlf-network/blob/master/CHANGELOG.md) to our repository which reveals our different releases along with a respective description/ enumeration of our changes.

## Versions 

We use the release 2.2 for all hyperledger fabric components besides the CA server and client where the latest release is 1.4. The binary files are compiled from these releases and might be incompatible to other versions.

## License

Our source code files are made available under the Apache License, Version 2.0 (Apache-2.0), located in the [LICENSE](LICENSE) file.

The included binaries are built from
 - fabric-ca-client [Hyperledger Fabric CA, Release 1.4.7](https://github.com/hyperledger/fabric-ca)
 - configtxgen [Hyperledger Fabric, Release 2.2](https://github.com/hyperledger/fabric)

both published under the Apache-2.0 license.

## Troubleshooting

* The error ```mount: /hyperledger: mount(2) system call failed: Connection timed out.``` arose when running our ```startNetwork.sh``` script and set up mounts for our Kubernetes cluster. Currently, we solve this issue by disabling any firewall running on our systems using the command ```sudo ufw disable```. This is just a workaround for testing, we hope to find a real fix in the near future.
