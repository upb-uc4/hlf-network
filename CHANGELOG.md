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
