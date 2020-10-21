#!/bin/bash

source "/tmp/hyperledger/scripts/util.sh"

set -e

export CA_ORG_HOST=_ca._tcp.rca-org${ORG_NUM}.hlf

echo "Enroll admin identity"
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org${ORG_NUM}/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/secrets/rca-org${ORG_NUM}/cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

fabric-ca-client enroll -u https://$ADMIN_IDENTITY_USER:$ADMIN_IDENTITY_PASSWORD@$CA_ORG_HOST

# Share admin certificate with other Pods
mkdir -p /tmp/hyperledger/shared/org${ORG_NUM}/msp/admincerts
cp /tmp/hyperledger/org${ORG_NUM}/admin/msp/signcerts/cert.pem /tmp/hyperledger/shared/org${ORG_NUM}/msp/admincerts/cert.pem

# Share admin certificate with CLI container
mkdir -p /tmp/hyperledger/org${ORG_NUM}/admin/msp/admincerts
cp /tmp/hyperledger/org${ORG_NUM}/admin/msp/signcerts/cert.pem /tmp/hyperledger/org${ORG_NUM}/admin/msp/admincerts/cert.pem

echo "Finished enrolling admins"

