#!/bin/bash

source "/tmp/hyperledger/scripts/util.sh"

set +e

sleep 10

log "Use CA-client to enroll admin"

export CA_ORG2_HOST=0.0.0.0:7052
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/secrets/cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/ca-client/

fabric-ca-client enroll -u https://$BOOTSTRAP_USER:$BOOTSTRAP_PASSWORD@$CA_ORG2_HOST

log "Use CA-client to register initial identities"

fabric-ca-client register \
  --id.name $PEER1_ORG2_IDENTITY_USER \
  --id.secret $PEER1_ORG2_IDENTITY_PASSWORD \
  --id.type peer \
  -u https://$CA_ORG2_HOST
fabric-ca-client register \
  --id.name $PEER2_ORG2_IDENTITY_USER \
  --id.secret $PEER2_ORG2_IDENTITY_PASSWORD \
  --id.type peer \
  -u https://$CA_ORG2_HOST
fabric-ca-client register \
  --id.name $ADMIN_ORG2_IDENTITY_USER \
  --id.secret $ADMIN_ORG2_IDENTITY_PASSWORD \
  --id.type user \
  --id.attrs "sysAdmin=true:ecert" \
  -u https://$CA_ORG2_HOST

log "Finished registering users"
