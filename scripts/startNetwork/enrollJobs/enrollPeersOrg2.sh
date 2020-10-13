#!/bin/bash

source "/tmp/hyperledger/scripts/util.sh"

set -e

export CA_ORG2_HOST=rca-org2.hlf:7055
export CA_TLS_HOST=tls-ca.hlf:7052


log "Enroll Peer1 at Org2-CA"

export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org2/peer1
export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/ca/org2-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
mkdir -p $FABRIC_CA_CLIENT_HOME/assets/ca
cp /tmp/hyperledger/org2/ca/crypto/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES

fabric-ca-client enroll -u https://peer1-org2:peer1PW@$CA_ORG2_HOST


log "Enroll Peer1 at TLS-CA"

export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org2/peer1
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/secrets/tls-ca/cert.pem
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
mkdir -p $FABRIC_CA_CLIENT_HOME/assets/tls-ca
#cp /tmp/hyperledger/org2/ca/ca-cert.pem $FABRIC_CA_CLIENT_HOME/assets/tls-ca/tls-ca-cert.pem

fabric-ca-client enroll -u https://peer1-org2:peer1PW@$CA_TLS_HOST --enrollment.profile tls --csr.hosts peer1-org2

mv /tmp/hyperledger/org2/peer1/tls-msp/keystore/*_sk /tmp/hyperledger/org2/peer1/tls-msp/keystore/key.pem


log "Enroll Peer2 at Org2-CA"

export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org2/peer2
export FABRIC_CA_CLIENT_TLS_CERTFILES=assets/ca/org2-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
mkdir -p $FABRIC_CA_CLIENT_HOME/assets/ca
cp /tmp/hyperledger/org2/ca/crypto/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES

fabric-ca-client enroll -u https://peer2-org2:peer2PW@$CA_ORG2_HOST


log "Enroll Peer2 at TLS-CA"

export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/secrets/tls-ca/cert.pem
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
mkdir -p $FABRIC_CA_CLIENT_HOME/assets/tls-ca
#cp /tmp/hyperledger/org2/ca/ca-cert.pem $FABRIC_CA_CLIENT_HOME/assets/tls-ca/tls-ca-cert.pem

fabric-ca-client enroll -u https://peer2-org2:peer2PW@$CA_TLS_HOST --enrollment.profile tls --csr.hosts peer2-org2

mv /tmp/hyperledger/org2/peer2/tls-msp/keystore/*_sk /tmp/hyperledger/org2/peer2/tls-msp/keystore/key.pem

echo "Enroll org2 admin identity"
# Note that we assume that peer 1 holds the admin identity
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org2/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=../../org2/peer1/assets/ca/org2-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -u https://admin-org2:org2AdminPW@$CA_ORG2_HOST


log "Distribute admin certificate across peers"

mkdir /tmp/hyperledger/org2/peer1/msp/admincerts
cp /tmp/hyperledger/org2/admin/msp/signcerts/cert.pem /tmp/hyperledger/org2/peer1/msp/admincerts/org2-admin-cert.pem
# usually this would happen out-of-band
mkdir /tmp/hyperledger/org2/peer2/msp/admincerts
cp /tmp/hyperledger/org2/admin/msp/signcerts/cert.pem /tmp/hyperledger/org2/peer2/msp/admincerts/org2-admin-cert.pem

