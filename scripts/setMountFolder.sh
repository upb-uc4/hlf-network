#!/bin/bash

source ./scripts/env.sh

rm assets/configtx.yaml
envsubst \$HL_MOUNT < assets/configtx-template.yaml > assets/configtx.yaml
