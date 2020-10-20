#!/bin/bash

source "/tmp/hyperledger/scripts/util.sh"

set -e

log "Use CA-client to enroll admin"

export CA_ORG2_HOST=0.0.0.0:7055
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/secrets/cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/ca-client/

fabric-ca-client enroll -u https://$BOOTSTRAP_USER:$BOOTSTRAP_PASSWORD@$CA_ORG2_HOST

log "Use CA-client to register initial identities"

fabric-ca-client register --id.name peer1-org2 --id.secret peer1PW --id.type peer -u https://$CA_ORG2_HOST
fabric-ca-client register --id.name peer2-org2 --id.secret peer2PW --id.type peer -u https://$CA_ORG2_HOST
fabric-ca-client register --id.name admin-org2 --id.secret org2AdminPW --id.type user -u https://$CA_ORG2_HOST
fabric-ca-client register --id.name user-org2 --id.secret org2UserPW --id.type user -u https://$CA_ORG2_HOST

log "Finished registering users"
