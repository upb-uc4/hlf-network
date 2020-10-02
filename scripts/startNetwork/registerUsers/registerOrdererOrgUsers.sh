#!/bin/bash

my_dir="$(dirname "$0")"
source "$my_dir/../util.sh"

set -e

log "Use CA-client to enroll admin"

export CA_ORDERER_HOST=0.0.0.0:7053

export FABRIC_CA_CLIENT_TLS_CERTFILES=ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/ca-client/
mkdir -p $FABRIC_CA_CLIENT_HOME
cp /tmp/hyperledger/fabric-ca/crypto/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES

fabric-ca-client enroll -u https://rca-org0-admin:rca-org0-adminpw@$CA_ORDERER_HOST

log "Use CA-client to register initial identities"

fabric-ca-client register --id.name orderer-org0 --id.secret ordererpw --id.type orderer -u https://$CA_ORDERER_HOST
fabric-ca-client register --id.name admin-org0 --id.secret org0adminpw --id.type admin --id.attrs "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert" -u https://$CA_ORDERER_HOST

log "Finished registering Orderer Org users"
