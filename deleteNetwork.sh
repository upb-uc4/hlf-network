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
  echo ""
}

# Delete CA servers and corresponding services
delete-ca "TLS root CA" "$K8S/tls-ca/tls-ca.yaml" "ca-tls-root" "$K8S/tls-ca/tls-ca-service.yaml"
delete-ca "Orderer Org CA" "$K8S/orderer-org-ca/orderer-org-ca.yaml" "rca-org0-root" "$K8S/orderer-org-ca/orderer-org-ca-service.yaml"
delete-ca "Org1 CA" "$K8S/org1-ca/org1-ca.yaml" "rca-org1-root" "$K8S/org1-ca/org1-ca-service.yaml"
delete-ca "Org2 CA" "$K8S/org2-ca/org2-ca.yaml" "rca-org2-root" "$K8S/org2-ca/org2-ca-service.yaml"

echo Deleting temporary directories
rm -rf $TMP_FOLDER
rm -rf $K8S
