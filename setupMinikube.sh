source env.sh

set -e

echo "Mounting tmp folder to minikube such that we can access it from the filesystem."
echo "Make sure that ""$TMP_FOLDER"" exists and can be edited by non-root users."
mkdir -p "$TMP_FOLDER"/hyperledger

minikube mount "$TMP_FOLDER"/hyperledger:/mnt/hyperledger/ &
sleep 3

echo "Successfully created mount!"
