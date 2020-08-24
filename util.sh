get_pods() {
  #1 - app name
  kubectl get pods -l app=$1 --field-selector status.phase=Running -n hlf-production-network --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | head -n 1
}

small_sep() {
  printf "%s\n" '---------------------------------------------------------------------------------'
}

sep() {
  printf "%s\n" '================================================================================='
}

header() {
  printf "\n"
  sep
  printf "$1\n"
  sep
}