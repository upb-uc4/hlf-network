#!/bin/bash

source env.sh

rm configtx.yaml
rm kind.yaml
envsubst \$HL_MOUNT < configtx-template.yaml > configtx.yaml
