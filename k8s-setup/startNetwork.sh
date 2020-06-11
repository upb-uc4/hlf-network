# Function definitions

get_pods() {
    kubectl get pods -l app=ca-tls-root --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'
}

sep() {
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}


# Setting environment variables
source ./env.sh

# Starting the Network
echo Starting Network
minikube start

sep

echo Creating TLS CA pod
kubectl create -f tls-ca.yaml
TLS_CA_NAME=$(get_pods)
echo Pod $TLS_CA_NAME created

sep

echo Creating TLS CA service
kubectl create -f tls-ca-service.yaml
CA_SERVER_HOST=$(minikube service ca-tls --url | cut -c 8-)
echo TLS CA service exposed on $CA_SERVER_HOST

sep

echo Copy TLS certificate to local folder
mkdir -p $TMP_FOLDER
kubectl cp default/$TLS_CA_NAME:etc/hyperledger/fabric-ca-server/ca-cert.pem $TMP_FOLDER/ca-cert.pem

sep

echo Use CA-client to enroll admin
cp $TMP_FOLDER/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES
echo $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES
echo ./$CA_CLIENT enroll -d -u https://tls-ca-admin:tls-ca-adminpw@$CA_SERVER_HOST
./$CA_CLIENT enroll -d -u https://tls-ca-admin:tls-ca-adminpw@$CA_SERVER_HOST




