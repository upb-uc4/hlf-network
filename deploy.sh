#!/bin/bash

source env.sh

BRANCH_TAG="develop"
VERBOSE=""

print_usage() {
  printf "Usage: ..."
  printf "./deploy -v -b [branch or tag]"
  printf "Use -v for verbose output and -b to specify a branch or tag (default develop)\n"
}


while getopts 'vb:' flag; do
  case "${flag}" in
    b) BRANCH_TAG="${OPTARG}"
       printf "Branch / Tag: $BRANCH_TAG selected\n" ;;
    v) VERBOSE="-d"
       printf "Verbose activated\n" ;;
    ?) print_usage
       exit 1 ;;
  esac
done

set -e

./scripts/setMountFolder.sh
./scripts/startNetwork.sh $VERBOSE
./scripts/installChaincode.sh $BRANCH_TAG