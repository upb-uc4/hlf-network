#!/bin/bash

source "/tmp/hyperledger/scripts/util.sh"

set -e

log "Use CA-client to enroll admin"

export CA_ORG1_HOST=0.0.0.0:7052
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/secrets/cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/ca-client/

fabric-ca-client enroll -u https://$BOOTSTRAP_USER:$BOOTSTRAP_PASSWORD@$CA_ORG1_HOST

log "Use CA-client to register initial identities"

fabric-ca-client register \
  --id.name $PEER1_ORG1_IDENTITY_USER \
  --id.secret $PEER1_ORG1_IDENTITY_PASSWORD \
  --id.type peer \
  -u https://$CA_ORG1_HOST
fabric-ca-client register \
  --id.name $PEER2_ORG1_IDENTITY_USER \
  --id.secret $PEER2_ORG1_IDENTITY_PASSWORD \
  --id.type peer \
  -u https://$CA_ORG1_HOST
fabric-ca-client register \
  --id.name $ADMIN_ORG1_IDENTITY_USER \
  --id.secret $ADMIN_ORG1_IDENTITY_PASSWORD \
  --id.type user \
  -u https://$CA_ORG1_HOST
fabric-ca-client register \
  --id.name $SCALA_ADMIN_ORG1_IDENTITY_USER \
  --id.secret $SCALA_ADMIN_ORG1_IDENTITY_PASSWORD \
  --id.type admin \
  -u https://$CA_ORG1_HOST
fabric-ca-client register \
  --id.name $SCALA_REGISTRATION_ADMIN_ORG1_IDENTITY_USER \
  --id.secret $SCALA_REGISTRATION_ADMIN_ORG1_IDENTITY_PASSWORD \
  --id.type admin \
  --id.attrs "hf.Registrar.Roles=client,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert" \
  -u https://$CA_ORG1_HOST 

log "Finished registering users"
