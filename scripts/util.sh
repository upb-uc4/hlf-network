#!/bin/bash

# Colors
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'
DEFAULT_COLOR=${YELLOW}

get_pods() {
  #1 - app name
  kubectl get pods -l app=$1 --field-selector status.phase=Running -n hlf --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | head -n 1
}

get_worker_ip() {
  kubectl get nodes -l uc4.cs.upb.de/kind-worker -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'
}

small_sep() {
  msg '--------------------------------------------------------------------------------'
}

sep() {
  msg '================================================================================'
}

header() {
  printf "\n"
  sep
  msg "$1"
  sep
}

log() {
   if [ "$1" = "-n" ]; then
      shift
      echo -n "##### `date '+%Y-%m-%d %H:%M:%S'` $*"
   else
      echo "##### `date '+%Y-%m-%d %H:%M:%S'` $*"
   fi
}

msg() {
  echo -e "${DEFAULT_COLOR}$1${NOCOLOR}"
}
