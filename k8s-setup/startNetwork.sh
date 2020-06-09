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

#echo Creating TLS CA service
#kubectl create -f tls-ca-service.yaml
#sleep 2

#sep

echo Creating TLS CA pod
kubectl create -f tls-ca.yaml
sleep 5

sep

echo Pod Names
TLS_CA_NAME=$(get_pods)
echo $TLS_CA_NAME

sep

echo Copy TLS certificate to local folder
mkdir -p $TMP_FOLDER
kubectl cp default/$TLS_CA_NAME:etc/hyperledger/fabric-ca-server/ca-cert.pem $TMP_FOLDER/ca-cert.pem
sleep 2

sep

echo Use CA-client to enroll admin
cp $TMP_FOLDER/ca-cert.pem $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES
echo $FABRIC_CA_CLIENT_HOME/$FABRIC_CA_CLIENT_TLS_CERTFILES
kubectl expose deployment ca-tls --type=NodePort --name=ca-tls --port 7052
CA_SERVER_HOST=$(minikube service ca-tls --url | cut -c 8-)
echo $CA_SERVER_HOST
./$CA_CLIENT enroll -d -u https://tls-ca-admin:tls-ca-adminpw@$CA_SERVER_HOST




