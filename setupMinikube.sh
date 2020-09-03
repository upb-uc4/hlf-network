source env.sh

set -e

echo "Mounting tmp folder to minikube such that we can access it from the filesystem."
echo "Make sure that ""$K8S_MOUNT"" exists and can be edited by non-root users."
mkdir -p "$K8S_MOUNT"/hyperledger

minikube mount "$K8S_MOUNT"/hyperledger:/mnt/hyperledger/ &
sleep 3

echo "Successfully created mount!"
