#!/bin/bash

source "/tmp/hyperledger/scripts/util.sh"

set -e

export CA_ORG_HOST=rca-org${ORG_NUM}.hlf:${ORG_CA_PORT}
export CA_TLS_HOST=tls-ca.hlf:7052


log "Enroll Peer at Org-CA"

export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org${ORG_NUM}/peer${PEER_NUM}
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/secrets/rca-org${ORG_NUM}/cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
mkdir -p $FABRIC_CA_CLIENT_HOME/assets/ca

fabric-ca-client enroll -u https://peer${PEER_NUM}-org${ORG_NUM}:peer${PEER_NUM}PW@$CA_ORG_HOST


log "Enroll Peer at TLS-CA"

export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/secrets/tls-ca/cert.pem
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
mkdir -p $FABRIC_CA_CLIENT_HOME/assets/tls-ca

fabric-ca-client enroll -u https://peer${PEER_NUM}-org${ORG_NUM}:peer${PEER_NUM}PW@$CA_TLS_HOST --enrollment.profile tls --csr.hosts peer${PEER_NUM}-org${ORG_NUM}

mv /tmp/hyperledger/org${ORG_NUM}/peer${PEER_NUM}/tls-msp/keystore/*_sk /tmp/hyperledger/org${ORG_NUM}/peer${PEER_NUM}/tls-msp/keystore/key.pem

# Provide admin certificate to peer
mkdir -p /tmp/hyperledger/org${ORG_NUM}/peer${PEER_NUM}/msp/admincerts
cp /tmp/hyperledger/shared/org${ORG_NUM}/msp/admincerts/cert.pem /tmp/hyperledger/org${ORG_NUM}/peer${PEER_NUM}/msp/admincerts/org${ORG_NUM}-admin-cert.pem

