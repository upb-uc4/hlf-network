#!/bin/bash

source "/tmp/hyperledger/scripts/util.sh"

set +e

sleep 10

log "Use CA-client to enroll admin"

export CA_ORDERER_HOST=0.0.0.0:7052
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/secrets/cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/ca-client/

fabric-ca-client enroll -u https://$BOOTSTRAP_USER:$BOOTSTRAP_PASSWORD@$CA_ORDERER_HOST

log "Use CA-client to register initial identities"

fabric-ca-client register \
  --id.name $ORDERER_ORG0_IDENTITY_USER \
  --id.secret $ORDERER_ORG0_IDENTITY_PASSWORD \
  --id.type orderer \
  -u https://$CA_ORDERER_HOST
fabric-ca-client register \
  --id.name $ADMIN_ORG0_IDENTITY_USER \
  --id.secret $ADMIN_ORG0_IDENTITY_PASSWORD \
  --id.type admin \
  --id.attrs 'hf.Registrar.Roles=client:ecert,hf.Registrar.Attributes=*:ecert,hf.Revoker=true:ecert,hf.GenCRL=true:ecert,admin=true:ecert' \
  -u https://$CA_ORDERER_HOST

log "Finished registering Orderer Org users"
