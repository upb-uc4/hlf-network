# Hyperledger Fabric Network on Kubernetes

![CI](https://github.com/upb-uc4/hlf-network/workflows/CI/badge.svg?branch=develop)

## Introduction

This repository contains scripts and configuration files for a basic Hyperledger Fabric network running on Kubernetes. The topology is based on the [Hyperledger Fabric CA operations guide (release 1.4)](
https://hyperledger-fabric-ca.readthedocs.io/en/latest/operations_guide.html). 

## Table of Contents

  * [Introduction](#introduction)
  * [Getting Started](#getting-started)
    * [TL;DR](#tl;dr)
    * [Setup](#setup)
    * [Deploy the Network](#deploy-the-network)
    * [Local Testing from Outside the Cluster](#local-testing-from-outside-the-cluster)
    * [Kubernetes Dashboard](#kubernetes-dashboard)
  * [Network Topology](#network-topology)
  * [Deployment Steps](#deployment-steps)
    * [TLS-CA](#tls-ca)
    * [Organizations and Enrollment-CAs](#organizations-and-enrollment-cas)
    * [Orderer](#orderer)
    * [CLIs and Channel Creation](#clis-and-channel-creation)
    * [Install and Invoke Chaincode](#install-and-invoke-chaincode)
    * [Further Readings](#further-readings)
  * [Changelog](#changelog)
  * [Versions](#versions)
  * [License](#license)
  * [Troubleshooting](#troubleshooting)

---
  
## Getting Started

### TL;DR

 1. Install [KinD](https://kind.sigs.k8s.io/docs/user/quick-start/) and [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
 2. Run `./restart.sh`

### Setup

For setting up our project, you need to install [KinD](https://kind.sigs.k8s.io/docs/user/quick-start/) and [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/). If you are new to Kubernetes, we suggest the [interactive tutorials](https://kubernetes.io/docs/tutorials/) provided by Kubernetes. 

### Deploy the Network

Deploy the network with these steps:
 1. Create a local kubernetes cluster: 
    ```
    ./overwriteKindCluster.sh
    ```
 2. Deploy the network:
    ```
    ./deploy.sh [-b <chaincode release/tag>] [-c <cluster mount>] [-t]
    ```
    The ```-b``` tag can be used to specify a chaincode tag or branch (develop is default).
    
    Use ```-t``` for local testing with the scala API, providing certificates through the filesystem and registering an admin with a fixed password.
    
    The ```-c``` option allows to specify the mount path for hyperledger. The default folder matches the configuration of the development cluster.
 3. To delete the cluster, run ```kind delete cluster```, to remove all files ```sudo rm -rf /data/development/hyperledger/```. 

For faster development, you can use 
```
./restart.sh [-b <chaincode branch or tag>] [-c <cluster mount>] [-t] [-d]
```
This script deploys two clusters to which the network is deployed alternating to reduce startup times. You can use `-d` to delete the clusters. The other flags are identical to the deploy script

### Local Testing from Outside the Cluster

To test your application locally without deploying it to the cluster, deploy the network (and cluster) with the testing flag: ```./restart.sh -t```.
This has the following side-effects: 
 - We generate a connection profile at `/tmp/hyperledger/connection_profile_kubernetes_local.yaml` that can be used to access the network from outside the cluster on your machine.
 - We register a test user with the fixed credentials: `test-admin:test-admin-pw`.
 - We provide all root certificates at `/tmp/hyperledger/`.
 - We output all environment variables needed to test the scala api. Just export the last three lines that look similar to:
   ```
   export UC4_KIND_NODE_IP=172.18.0.3
   export UC4_CONNECTION_PROFILE=/tmp/hyperledger/connection_profile_kubernetes_local.yaml
   export UC4_TESTBASE_TARGET=PRODUCTION_NETWORK
   ```

### Kubernetes Dashboard

Kubernetes provides a [dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) which helps with debugging and controlling the cluster. To install the dasboard, run `kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml`. Execute `kubectl proxy` to make the dashboard available under http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/.

To access the dashboard, you need to generate a Bearer Token. To do so, just run the follwing commands ([reference](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md)) in your command line:
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF
```
```
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
```
You can then execute `kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
` to see your freshly generated Bearer Token and log into the dashboard.


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
Using these CLIs, we can create a channel and let peers join it. 

This command generates the mychannel.block on peer1 which can be used by other peers in the network to join the channel:
```
channel create \
         -c mychannel \
         -f /tmp/hyperledger/org1/peer1/assets/channel.tx \
         -o orderer-org0:7050 \
         --outputBlock /tmp/hyperledger/org1/peer1/assets/mychannel.block \
         --tls \
         --cafile /tmp/hyperledger/org1/peer1/tls-msp/tlscacerts/tls-tls-ca-hlf-7052.pem
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
4. The instantiating process of version v1.4 is replaced by an approval given by the peers for their organization. 
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

## Changelog

To get an overview of our developmental process, we tagged our releases and added a [Changelog](https://github.com/upb-uc4/hlf-network/blob/master/CHANGELOG.md) to our repository which reveals our different releases along with a respective description/ enumeration of our changes.

## Versions 

We use the release 2.2 for all hyperledger fabric components besides the CA server and client where the latest release is 1.4.

## License

Our source code files are made available under the Apache License, Version 2.0 (Apache-2.0), located in the [LICENSE](LICENSE) file.

## Troubleshooting

* The error ```mount: /hyperledger: mount(2) system call failed: Connection timed out.``` arose when running our ```startNetwork.sh``` script and set up mounts for our Kubernetes cluster. Currently, we solve this issue by disabling any firewall running on our systems using the command ```sudo ufw disable```. This is just a workaround for testing, we hope to find a real fix in the near future.
* To fix 
    ```
    =================================================================================
    Starting Docker in Docker in Kubernetes
    =================================================================================
    deployment.apps/dind created
    service/dind created
    error: no matching resources found
    ```
    add `sleep 10` between creation and waiting for a pod. If this does not help, try reinstalling the current version of kubectl (https://kubernetes.io/docs/tasks/tools/install-kubectl/)
