if [ -z "$1" ]
then
  echo "Usage: ./readCert.sh path-to-cert"
else
  openssl x509 -in "$1" -text -noout
fi
