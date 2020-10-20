#!/bin/bash

source "/tmp/hyperledger/scripts/util.sh"

set -e

log "Use CA-client to enroll admin"

export CA_ORG1_HOST=0.0.0.0:7054
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/secrets/cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/ca-client/

fabric-ca-client enroll -u https://$BOOTSTRAP_USER:$BOOTSTRAP_PASSWORD@$CA_ORG1_HOST

log "Use CA-client to register initial identities"

fabric-ca-client register --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://$CA_ORG1_HOST
fabric-ca-client register --id.name peer2-org1 --id.secret peer2PW --id.type peer -u https://$CA_ORG1_HOST
fabric-ca-client register --id.name admin-org1 --id.secret org1AdminPW --id.type user -u https://$CA_ORG1_HOST
fabric-ca-client register --id.name scala-admin-org1 --id.secret scalaAdminPW --id.type admin -u https://$CA_ORG1_HOST
fabric-ca-client register \
    --id.name scala-registration-admin-org1 \
    --id.secret scalaAdminPW \
    --id.type admin \
    --id.attrs "hf.Registrar.Roles=client,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert" \
    -u https://$CA_ORG1_HOST 
fabric-ca-client register --id.name user-org1 --id.secret org1UserPW --id.type user -u https://$CA_ORG1_HOST

log "Finished registering users"
