#!/bin/bash

export DEBUG=""
if [[ $1 == "-d" ]]; then
  export DEBUG="-d"
fi

./deleteNetwork.sh
./startNetwork.sh $DEBUG