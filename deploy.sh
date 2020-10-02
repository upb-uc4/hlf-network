#!/bin/bash

BRANCH_TAG="develop"
CONFIG_FILE="default-config.yaml"
VERBOSE=""

print_usage() {
  printf "Usage: ./deploy -v -b [branch or tag] -c [custom config file]\n"
  printf "Use -v for verbose output and -b to specify a branch or tag (default develop)\n"
  printf "Use -c to specify a custom config file for production deployment\n"
}


while getopts 'vb:c:' flag; do
  case "${flag}" in
    b) BRANCH_TAG="${OPTARG}"
       printf "Branch / Tag: %s selected\n" "$BRANCH_TAG" ;;
    v) VERBOSE="-d"
       printf "Verbose activated\n" ;;
    c) CONFIG_FILE="${OPTARG}"
       if [ -f "$CONFIG_FILE" ]; then
         printf "Using config: %s" "$CONFIG_FILE"
       else
         echo "Config file $CONFIG_FILE does not exist."
         exit
       fi ;;
    ?) print_usage
       exit 1 ;;
  esac
done

set -e
sed -e 's/:[^:\/\/]/="/g;s/$/"/g;s/ *=/=/g' $CONFIG_FILE > env.sh
sed -i -e 's/^/export /' env.sh


./scripts/setMountFolder.sh
./scripts/startNetwork.sh $VERBOSE
./scripts/installChaincode.sh $BRANCH_TAG