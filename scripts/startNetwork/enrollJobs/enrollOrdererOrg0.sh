#!/bin/bash

source "/tmp/hyperledger/scripts/util.sh"

set -e

export CA_ORDERER_HOST=rca-org0.hlf:7052
export CA_TLS_HOST=tls-ca.hlf:7052


log "Enroll Orderer at Org0 enrollment ca"

export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org0/orderer
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/secrets/rca-org0/cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
mkdir -p $FABRIC_CA_CLIENT_HOME/assets/ca

fabric-ca-client enroll \
  -u https://$ORDERER_ORG0_IDENTITY_USER:$ORDERER_ORG0_IDENTITY_PASSWORD@$CA_ORDERER_HOST


log "Enroll Orderer at TLS Ca"

export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/secrets/tls-ca/cert.pem
mkdir -p $FABRIC_CA_CLIENT_HOME/assets/tls-ca

fabric-ca-client enroll \
  -u https://$ORDERER_TLS_IDENTITY_USER:$ORDERER_TLS_IDENTITY_PASSWORD@$CA_TLS_HOST \
  --enrollment.profile tls \
  --csr.hosts orderer-org0

mv /tmp/hyperledger/org0/orderer/tls-msp/keystore/*_sk /tmp/hyperledger/org0/orderer/tls-msp/keystore/key.pem

log "Enroll Org0's Admin"

export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org0/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/secrets/rca-org0/cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll \
  -u https://$ADMIN_ORG0_IDENTITY_USER:$ADMIN_ORG0_IDENTITY_PASSWORD@$CA_ORDERER_HOST

# Provide admin certificate to other entities
mkdir -p /tmp/hyperledger/shared/org0/msp/admincerts
cp /tmp/hyperledger/org0/admin/msp/signcerts/cert.pem \
  /tmp/hyperledger/shared/org0/msp/admincerts/cert.pem

# Provide admin certificate to orderer
mkdir -p /tmp/hyperledger/org0/orderer/msp/admincerts
cp /tmp/hyperledger/org0/admin/msp/signcerts/cert.pem \
  /tmp/hyperledger/org0/orderer/msp/admincerts/orderer-admin-cert.pem

