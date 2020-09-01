#!/bin/bash

my_dir="$(dirname "$0")"
source "$my_dir/../utils.sh"

set -e

log "Use CA-client to enroll admin"

export CA_ORG1_HOST=0.0.0.0:7054
export FABRIC_CA_CLIENT_TLS_CERTFILES=tls-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/ca-client/
mkdir -p $FABRIC_CA_CLIENT_HOME
cp /tmp/hyperledger/fabric-ca/crypto/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES

fabric-ca-client enroll -u https://rca-org1-admin:rca-org1-adminpw@$CA_ORG1_HOST

log "Use CA-client to register initial identities"


fabric-ca-client register --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://$CA_ORG1_HOST
fabric-ca-client register --id.name peer2-org1 --id.secret peer2PW --id.type peer -u https://$CA_ORG1_HOST
fabric-ca-client register --id.name admin-org1 --id.secret org1AdminPW --id.type user -u https://$CA_ORG1_HOST
fabric-ca-client register --id.name scala-admin-org1 --id.secret scalaAdminPW --id.type admin -u https://$CA_ORG1_HOST
fabric-ca-client register --id.name user-org1 --id.secret org1UserPW --id.type user -u https://$CA_ORG1_HOST

log "Finished registering users"
