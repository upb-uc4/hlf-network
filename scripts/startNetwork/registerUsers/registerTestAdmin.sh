#!/bin/bash

source "/tmp/hyperledger/scripts/util.sh"

set +e

export CA_ORG1_HOST=0.0.0.0:7052
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/secrets/cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/ca-client/

log "Use CA-client to register test identities"

# hf.Registrar.Attributes=* to allow tests setting arbitrary attributes

fabric-ca-client register \
  --id.name "test-admin" \
  --id.secret "test-admin-pw" \
  --id.type admin \
  --id.attrs 'hf.Registrar.Roles=client:ecert,hf.Registrar.Attributes="*":ecert,hf.Revoker=true:ecert,hf.GenCRL=true:ecert,admin=true:ecert,sysAdmin=true:ecert' \
  -u https://$CA_ORG1_HOST

log "Finished registering test admin"
