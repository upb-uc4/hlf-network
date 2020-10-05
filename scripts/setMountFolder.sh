#!/bin/bash

source ./scripts/env.sh

rm -rf assets/configtx.yaml

envsubst \$HL_MOUNT < assets/configtx-template.yaml > assets/configtx.yaml
