#!/bin/bash

# Fix for weird permission denied errors from mounts using hostPath:
# https://kubernetes.io/docs/concepts/storage/volumes/#hostpath
#
# The files or directories created on the underlying hosts are only writable by root. You either need to run your
# process as root in a privileged Container or modify the file permissions on the host to be able to write to a
# hostPath volume.

set +e
mkdir -p $HL_MOUNT/uc4
chmod 777 $HL_MOUNT/uc4
mkdir -p $HL_MOUNT/uc4/chaincode
chmod 777 $HL_MOUNT/uc4/chaincode
set -e