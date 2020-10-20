#!/bin/bash

source "/tmp/hyperledger/scripts/util.sh"

set -e

log "Use CA-client to enroll admin"

export TLS_CA_HOST=0.0.0.0:7052
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/secrets/cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/ca-client/

echo $BOOTSTRAP_USER:$BOOTSTRAP_PASSWORD
fabric-ca-client enroll -u https://$BOOTSTRAP_USER:$BOOTSTRAP_PASSWORD@$TLS_CA_HOST

log "Use CA-client to register initial identities"

fabric-ca-client register \
  --id.name $PEER1_ORG1_IDENTITY_USER \
  --id.secret $PEER1_ORG1_IDENTITY_PASSWORD \
  --id.type peer \
  -u https://$TLS_CA_HOST
fabric-ca-client register \
  --id.name $PEER2_ORG1_IDENTITY_USER \
  --id.secret $PEER2_ORG1_IDENTITY_PASSWORD \
  --id.type peer \
  -u https://$TLS_CA_HOST
fabric-ca-client register \
  --id.name $PEER1_ORG2_IDENTITY_USER \
  --id.secret $PEER1_ORG2_IDENTITY_PASSWORD \
  --id.type peer \
  -u https://$TLS_CA_HOST
fabric-ca-client register \
  --id.name $PEER2_ORG2_IDENTITY_USER \
  --id.secret $PEER2_ORG2_IDENTITY_PASSWORD \
  --id.type peer \
  -u https://$TLS_CA_HOST
fabric-ca-client register \
  --id.name $ORDERER_ORG0_IDENTITY_USER \
  --id.secret $ORDERER_ORG0_IDENTITY_PASSWORD \
  --id.type orderer \
  -u https://$TLS_CA_HOST

log "Finished registering TLS users"
