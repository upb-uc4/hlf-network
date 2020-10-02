#!/bin/bash

source ./scripts/env.sh

set +e
rm assets/configtx.yaml
set -e

envsubst \$HL_MOUNT < assets/configtx-template.yaml > assets/configtx.yaml
