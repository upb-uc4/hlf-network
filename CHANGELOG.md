## [v.0.17.0](https://github.com/upb-uc4/hlf-network/compare/v0.16.0...v0.17.0) (Draft)

## Feature

 - Add `sysadmin=true:ecert` attribute to org1-admin, org2-admin and scala users. If added to an enrollment request, this attribute is written to the certificate of a user [#114](https://github.com/upb-uc4/hlf-network/pull/114)

## [v.0.16.0](https://github.com/upb-uc4/hlf-network/compare/v0.13.0...v0.16.0) (2021-01-21)

## Feature

 - Add secret containing the version of the hlf-network to uc4-lagom namespace [#110](https://github.com/upb-uc4/hlf-network/pull/110)
 - Reduce batch timeout to improve response times [#112](https://github.com/upb-uc4/hlf-network/pull/112)

# [v.0.13.0](https://github.com/upb-uc4/hlf-network/compare/v0.12.0...v0.13.0) (2020-11-30) 

## Documentation

 - Update REAMDE.md [#105](https://github.com/upb-uc4/hlf-network/pull/105)
 
## Feature
 
 - Set chaincode version during install as defined in chaincode source package [#106](https://github.com/upb-uc4/hlf-network/pull/106)

## Refactoring

 - Add necessary environment variables to output when using `-t` flag and fix wrong CA names [#104](https://github.com/upb-uc4/hlf-network/pull/104)
 - Update scripts to support chaincode published as jar instead of building it ourselves [#100](https://github.com/upb-uc4/hlf-network/pull/100)

# [v.0.12.0](https://github.com/upb-uc4/hlf-network/compare/v0.11.3...v0.12.0) (2020-11-06) 

## Feature
 
 - Copy *connection_profile_kubernetes_local* to `/tmp/hyperledger` when using `-t` flag

## Bug Fixes 

 - Fix restart script failing if no cluster exists
 - Catch wait for peers failing if resources are not registered yet, wait and retry

# [v.0.11.3](https://github.com/upb-uc4/hlf-network/compare/v0.11.2...v0.11.3) (2020-11-04) 

## Feature
 - Add templating of *connection_profile_kubernetes_local.yaml* for local testing and development
 - Output kubernetes worker port of dev clusters when using `-t` flag
 
## Refactoring

 - Call the "registerUsers" scripts from the kubernetes PostStart lifecycle hook.
 - Clean up output of the deployment scripts
 - Make the coding style more consistent

# [v.0.11.2](https://github.com/upb-uc4/hlf-network/compare/v0.11.1...v0.11.2) (2020-10-28) 

## Bug Fixes 

 - Wrong address in peer configuration caused chaincode registration failure

# [v.0.11.1](https://github.com/upb-uc4/hlf-network/compare/v0.11.0...v0.11.1) (2020-10-28) 

## Bug Fixes 

 - Fix bug that chaincode containers cannot send messages to their peer

## Feature
 
 - Add `-t` tag for testing that copies certificates to the filesystem and registers a testing admin for running local test

## Refactor 
 
 - Remove `-d` debug flag since it was not used anymore
 - Remove legacy support for providing certifcates through the filesystem instead of secrets in lagom


# [v.0.11.0](https://github.com/upb-uc4/hlf-network/compare/v0.10.2...v0.11.0) (2020-10-26) 

## Feature
 
 - Add credentials stored in k8s secrets for usernames and passwords
 - Add secrets containing credentials to lagom namespace (credentials.scala-admin-org1, credentials.scala-registration-admin-org1)
 - Add development script with faster restart times that uses alternating clusters 
 - Add dind container to each peer's Pod

## Refactor 
 
 - Name service ports
 - Change https listen ports of tls-ca, rca-org0, rca-org1, rca-org2 to 7052


# [v.0.10.2](https://github.com/upb-uc4/hlf-network/compare/v0.10.1...v0.10.2) (2020-10-20) 

## Refactor
 
 - Provide secrets and configmap to lagom namespace
 - Change paths in connection_profile_kubernetes
 
 
# [v.0.10.1](https://github.com/upb-uc4/hlf-network/compare/v0.10.0...v0.10.1) (2020-10-20) 

## Refactor
 
 - Generate usernames and passwords of CAs into k8s secrets
 - Replace Jobs by initContainers to keep data on the same Pod (e.g. enrollment and use of credentials)
 - Remove templating behavior by moving functionality in the network
 - Generate genesis block in the orderers Pod instead of the start script
 - Reduce shared mounts to a minimum
 

# [v.0.10.0](https://github.com/upb-uc4/hlf-network/compare/v0.9.0...v0.10.0) (2020-10-13) 

## Documentation

 - Add instructions on how to deploy and use the Kubernetes Dashbaord.

## Refactor
 
 - Refactor kubernetes config files
 - Change namespace from `hlf-production-network` to `hlf` and service `ca-tls` to `tls-ca`


# [v.0.9.0](https://github.com/upb-uc4/hlf-network/compare/v0.8.0...v0.9.0) (2020-10-05) 

## Feature

 - Add registration admin user for registering new users from Org1
 - Add configuration files to support multiple deployments
 
## Refactor
 
 - Remove Minikube related scripts since we do not support Minikube anymore
 - Add getopts to deploy script
 - Switch to only one script for setting up a dev cluster
 - Move scripts to scripts folder
 - Refactor project structure and cleanup code
 
 
# [v.0.8.0](https://github.com/upb-uc4/hlf-network/compare/v0.7.2...v0.8.0) (2020-09-11) 

## Feature

 - Support of private data collections on the initial channel
 
## Refactor
 
 - Adjust deployments scripts to work on the server 

# [v.0.7.2](https://github.com/upb-uc4/hlf-network/compare/v0.7.1...v0.7.2) (2020-09-08)

## Feature

 - Support dynamic mount paths for multiple clusters

## Testing

 - Change testing pipelines to support the new dynamic mount paths

# [v.0.7.1](https://github.com/upb-uc4/hlf-network/compare/v0.7.0...v0.7.1) (2020-09-02)

## Feature 

 - Support Kubernetes in Docker (KinD) besides Minikube
 
## Refactor

 - Move scripts for enrollment and registration into the cluster
 - Remove templating and replacement of environment variables in files by static network parameters

## Testing 

 - Add CI pipeline for KinD that runs the network and installs chaincode
 
## Documentation

 - Add instructions on how to use the network on KinD and Minikube 
 
# [v.0.7.0](https://github.com/upb-uc4/hlf-network/compare/v0.6.0...v0.7.0) (2020-08-28)

## Refactor

 - Change chaincode repository url
 - Refactor scripts

## Documentation

 - Update and extend README.md

# [v.0.6.0](https://github.com/upb-uc4/hlf-network/compare/v0.5.1...v0.6.0) (2020-08-14)

## Feature

 - Add CouchDB container to each Peer's Pod

# [v0.5.1](https://github.com/upb-uc4/hlf-network/compare/v0.5.0...v0.5.1) (2020-08-11)

## Feature

 - Connect the network with Scala API
 - Add chaincode installation following the v2 chaincode lifecycle pattern
   - Build chaincode
   - Package chaincode
   - Install chaincode on all peers
   - Approve chaincode by both organizations
   - Commit chaincode

## Usability

 - Add utility scripts for easier debugging
 - Add pipeline that tests installation 
 - Provide certificates and a test user for usage in Scala API 
 

# [v0.5.0](https://github.com/upb-uc4/hlf-network/compare/v0.4.0...v0.5.0) (2020-07-31)

## Feature

 - Add CLI containers for organizations
 - Add services for peers
 - Add channel join for all peers
 
## Bug Fixes

 - Minor bugfixes in configuration files
 

# \[v0.4.0\] (2020-07-17)

## Feature
    
 - Hyperledger network consisting of
   - CA servers for three organizations
   - An organization with an orderer service
   - two organizations with two peers each
   - A TLS CA server for server-side TLS
   - Scripts for starting and resetting the network
