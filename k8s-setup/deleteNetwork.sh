# Set environment variables

source ./env.sh

delete-ca() {
  #1 - name
  #2 - deployment yaml
  #3 - app
  #4 - service yaml
  echo Deleting $1 deployment
  kubectl delete -f $2
  echo Waiting until all pods are terminated
  kubectl wait --for=delete pod -l app=$3 --timeout=60s
  echo Deleting $1 service
  kubectl delete -f $4
}

# Delete CA servers and corresponding services
delete-ca "TLS root CA" "tls-ca/tls-ca.yaml" "ca-tls-root" "tls-ca/tls-ca-service.yaml"
delete-ca "Orderer Org CA" "orderer-org-ca/orderer-org-ca.yaml" "rca-org0-root" "orderer-org-ca/orderer-org-ca-service.yaml"
delete-ca "Org1 CA" "org1-ca/org1-ca.yaml" "rca-org1-root" "org1-ca/org1-ca-service.yaml"
delete-ca "Org2 CA" "org2-ca/org2-ca.yaml" "rca-org2-root" "org2-ca/org2-ca-service.yaml"

# Remove tmp dir
echo Deleting tmp directory
rm -rf $TMP_FOLDER
