# Function definitions

get_pods() {
    kubectl get pods --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'
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
kubectl apply -f tls-ca-server.yaml
sep

echo Pod Names
TLS_CA_NAME=$(get_pods)
sep

echo Copy TLS certificate to local folder 
mkdir -p $TMP_FOLDER


echo $POD
kubectl cp default/$TLS_CA_NAME:etc/hyperledger/fabric-ca-server/ca-cert.pem $TMP_FOLDER/ca-cert.pem

