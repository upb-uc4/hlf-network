export IP="$(minikube ip)"
export PEERS_TLSCACERTS=tls-$( echo ${IP} | tr '.' '-' )-30905.pem
