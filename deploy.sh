#!/bin/bash

BRANCH_TAG="develop"
VERBOSE=""

print_usage() {
  printf "Usage: ..."
  printf "./deploy -v -b [branch or tag]"
  printf "Use -v for verbose output and -b to specify a branch or tag (default develop)\n"
}


while getopts 'vb:c:' flag; do
  case "${flag}" in
    b) BRANCH_TAG="${OPTARG}"
       printf "Branch / Tag: %s selected\n" "$BRANCH_TAG" ;;
    v) VERBOSE="-d"
       printf "Verbose activated\n" ;;
    c) CONFIG_FILE="${OPTARG}"
       printf "Using config: %s" "$CONFIG_FILE" ;;
    ?) print_usage
       exit 1 ;;
  esac
done

set -e
sed -e 's/:[^:\/\/]/="/g;s/$/"/g;s/ *=/=/g' default-config.yaml > env.sh
sed -i -e 's/^/export /' env.sh


./scripts/setMountFolder.sh
./scripts/startNetwork.sh $VERBOSE
./scripts/installChaincode.sh $BRANCH_TAG