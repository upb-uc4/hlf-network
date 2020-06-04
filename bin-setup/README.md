# HLF-Production-Network

## Create TLS server with initial admin account
`./fabric-ca-server init -b tls-admin:tls-adminpw`

## Enroll TLS CA admin -> generates certificate in client folders 
`./fabric-ca-client enroll -d -u https://tls-admin:tls-adminpw@localhost:7054 --tls.certfiles tls-root-cert/tls-ca-cert.pem  --enrollment.profile tls --csr.hosts 'localhost' --mspdir tls-ca/tlsadmin/msp`

## Create enrollment CA server with initial admin account
`./fabric-ca-server init -b tls-admin:tls-adminpw`

## Register and enroll enrollment CA admin at TLS CA
`./fabric-ca-client register -d --id.name rcaadmin --id.secret rcaadminpw -u https://localhost:7054  --tls.certfiles tls-root-cert/tls-ca-cert.pem --mspdir tls-ca/tlsadmin/msp`
`./fabric-ca-client enroll -d -u https://rcaadmin:rcaadminpw@localhost:7054 --tls.certfiles tls-root-cert/tls-ca-cert.pem --enrollment.profile tls --csr.hosts 'localhost' --mspdir tls-ca/rcaadmin/msp`

## Enroll enrollment CA admin at enrollment CA
`./fabric-ca-client enroll -d -u https://rcaadmin:rcaadminpw@localhost:7055 --tls.certfiles tls-root-cert/tls-ca-cert.pem --csr.hosts 'localhost' --mspdir org1-ca/rcaadmin/msp`

