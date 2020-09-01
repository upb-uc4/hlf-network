#!/bin/bash

my_dir="$(dirname "$0")"
source "$my_dir/utils.sh"

set -e

log "Use CA-client to enroll admin"

export CA_ORG2_HOST=0.0.0.0:7055
export FABRIC_CA_CLIENT_TLS_CERTFILES=tls-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/ca-client/
mkdir -p $FABRIC_CA_CLIENT_HOME
cp /tmp/hyperledger/fabric-ca/crypto/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES

fabric-ca-client enroll -u https://rca-org2-admin:rca-org2-adminpw@$CA_ORG2_HOST

log "Use CA-client to register initial identities"


fabric-ca-client register --id.name peer1-org2 --id.secret peer1PW --id.type peer -u https://$CA_ORG2_HOST
fabric-ca-client register --id.name peer2-org2 --id.secret peer2PW --id.type peer -u https://$CA_ORG2_HOST
fabric-ca-client register --id.name admin-org2 --id.secret org2AdminPW --id.type user -u https://$CA_ORG2_HOST
fabric-ca-client register --id.name user-org2 --id.secret org2UserPW --id.type user -u https://$CA_ORG2_HOST

log "Finished registering users"
