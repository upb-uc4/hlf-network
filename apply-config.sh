source ./env.sh
source ./settings.sh

if test -f ./user-settings.sh; then
  source ./user-settings.sh
fi

if [ ! -d "$K8S" ]; then
  mkdir -p $K8S
  cp -a k8s-templates/. $K8S

  for file in `find "$K8S" -name "*.yaml" -type f` ; do
  envsubst < $file > $file.tmp && mv $file.tmp $file
  done
fi
