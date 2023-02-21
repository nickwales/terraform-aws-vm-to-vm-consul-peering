#!/bin/bash

INSTANCE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
### Export default vars
cat <<EOT >> /etc/profile
export PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4) 
export PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
export VAULT_ADDR="http://vault.service.consul:8200"
export VAULT_SKIP_VERIFY=true
EOT

# Add hashicorp key and install vault, consul, and envconsul
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update
apt install -y vault consul jq dnsmasq unzip

### Set default consul client config
mkdir /etc/consul.d/certs/

cat <<EOT > /etc/consul.d/certs/ca.pem
-----BEGIN CERTIFICATE-----
MIIC7jCCApOgAwIBAgIQXr5pAxPQBhawWn+1dh2G1TAKBggqhkjOPQQDAjCBuTEL
MAkGA1UEBhMCVVMxCzAJBgNVBAgTAkNBMRYwFAYDVQQHEw1TYW4gRnJhbmNpc2Nv
MRowGAYDVQQJExExMDEgU2Vjb25kIFN0cmVldDEOMAwGA1UEERMFOTQxMDUxFzAV
BgNVBAoTDkhhc2hpQ29ycCBJbmMuMUAwPgYDVQQDEzdDb25zdWwgQWdlbnQgQ0Eg
MTI1OTM2MDk3OTAzNzI4MjgwNzgwMzg2NDYwOTQwNDM4OTYzOTI1MB4XDTIzMDIx
OTA3MDAxM1oXDTMzMDIxNjA3MDAxM1owgbkxCzAJBgNVBAYTAlVTMQswCQYDVQQI
EwJDQTEWMBQGA1UEBxMNU2FuIEZyYW5jaXNjbzEaMBgGA1UECRMRMTAxIFNlY29u
ZCBTdHJlZXQxDjAMBgNVBBETBTk0MTA1MRcwFQYDVQQKEw5IYXNoaUNvcnAgSW5j
LjFAMD4GA1UEAxM3Q29uc3VsIEFnZW50IENBIDEyNTkzNjA5NzkwMzcyODI4MDc4
MDM4NjQ2MDk0MDQzODk2MzkyNTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABOPg
ar4OI7hxcRhASxcAO82PUqSaKYtqXq3NtlN6m+frK0spEdE0V+PFsFG+ShzN9ixA
jST7XnayooH2HthZ1Y6jezB5MA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTAD
AQH/MCkGA1UdDgQiBCC4ixqU1JJzzHOjEXsshpf6doUj+KeB7UosrZdiQXc2GTAr
BgNVHSMEJDAigCC4ixqU1JJzzHOjEXsshpf6doUj+KeB7UosrZdiQXc2GTAKBggq
hkjOPQQDAgNJADBGAiEA5Kh4XJptbgUHYUXUUIrb9Vnz/DZMi0cSs3Ec9NyEt3gC
IQDVqFOhawLTczp1xQVZZFYzEZzyLnIJABxWmRriL8mGPg==
-----END CERTIFICATE-----
EOT

cat <<EOT > /etc/consul.d/certs/cert_file.pem
-----BEGIN CERTIFICATE-----
MIICrzCCAlagAwIBAgIQRIIYD8phExbA4tNrfprUCTAKBggqhkjOPQQDAjCBuTEL
MAkGA1UEBhMCVVMxCzAJBgNVBAgTAkNBMRYwFAYDVQQHEw1TYW4gRnJhbmNpc2Nv
MRowGAYDVQQJExExMDEgU2Vjb25kIFN0cmVldDEOMAwGA1UEERMFOTQxMDUxFzAV
BgNVBAoTDkhhc2hpQ29ycCBJbmMuMUAwPgYDVQQDEzdDb25zdWwgQWdlbnQgQ0Eg
MTI1OTM2MDk3OTAzNzI4MjgwNzgwMzg2NDYwOTQwNDM4OTYzOTI1MB4XDTIzMDIx
OTA3MDAyMloXDTI4MDIxODA3MDAyMlowHDEaMBgGA1UEAxMRc2VydmVyLmRjMi5j
b25zdWwwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAATgqzhIzGFubyKgfG73TWz+
NFNx7bllrREqPyWQdkkdoXMwzx0SjutAiNeFl3dtf6+xuOHkkMKSjld0o1uDsQz5
o4HbMIHYMA4GA1UdDwEB/wQEAwIFoDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYB
BQUHAwIwDAYDVR0TAQH/BAIwADApBgNVHQ4EIgQgfPUQ9/SYXo4hBePYpPlZDKm/
/Wz7qbJ1zWoV/qKb98AwKwYDVR0jBCQwIoAguIsalNSSc8xzoxF7LIaX+naFI/in
ge1KLK2XYkF3NhkwQQYDVR0RBDowOIISY29uc3VsLXNlcnZlcjEtZGMyghFzZXJ2
ZXIuZGMyLmNvbnN1bIIJbG9jYWxob3N0hwR/AAABMAoGCCqGSM49BAMCA0cAMEQC
IEN7greK873+F4JOWBInAjIT0tAPtKl7ppKsKFSGa4KgAiA8M6u2g/ZOP+I9DZAO
D2kHkDmI177EydG8oVx/vIVbNw==
-----END CERTIFICATE-----
EOT

cat <<EOT > /etc/consul.d/certs/key_file.pem
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIMq+hLbLefEIpj4MCBwKRr+rMtjPkPPqwc8iNZx9z9yVoAoGCCqGSM49
AwEHoUQDQgAE4Ks4SMxhbm8ioHxu901s/jRTce25Za0RKj8lkHZJHaFzMM8dEo7r
QIjXhZd3bX+vsbjh5JDCko5XdKNbg7EM+Q==
-----END EC PRIVATE KEY-----
EOT

cat <<EOT > /etc/consul.d/consul.hcl
server = true
datacenter = "dc2"
data_dir = "/opt/consul"
client_addr = "0.0.0.0"
advertise_addr = "${INSTANCE_IP}"
bootstrap_expect = 1
ui_config = {
    enabled = true
}

acl {
  enabled = true
  default_policy = "deny"
  down_policy = "extend-cache"
  enable_token_persistence = true

  tokens {
    initial_management = "root"
    agent = "root"
    default = ""
  }
}

ports = {
  https    = 8501
  grpc     = 8502
  grpc_tls = 8503
}

peering {
  enabled = true
}

leave_on_terminate = true

connect = {
  enabled = true
}

tls {
  defaults {
    ca_file   = "/etc/consul.d/certs/ca.pem"
    cert_file = "/etc/consul.d/certs/cert_file.pem"
    key_file  = "/etc/consul.d/certs/key_file.pem"

    verify_incoming = true
    verify_outgoing = true
  }
  internal_rpc {
    verify_server_hostname = true
  }
}

encrypt = "aPuGh+5UDskRAbkLaXRzFoSOcSM+5vAK+NEYOWHJH7w="

auto_encrypt = {
  allow_tls = true
}
EOT

systemctl daemon-reload
systemctl enable consul --now
sleep 10

# bootstrap=$(consul acl bootstrap -format json)
# echo $bootstrap > /root/bootstrap.json
# secret_id=$(echo ${bootstrap} | jq -r .SecretID)
echo "export CONSUL_HTTP_TOKEN=root" >> /etc/profile
