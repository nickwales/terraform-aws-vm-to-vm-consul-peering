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
mkdir /etc/consul.d/certs

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
MIICsTCCAlegAwIBAgIRAK8UBFH/3lJwKEMX1xiXI1MwCgYIKoZIzj0EAwIwgbkx
CzAJBgNVBAYTAlVTMQswCQYDVQQIEwJDQTEWMBQGA1UEBxMNU2FuIEZyYW5jaXNj
bzEaMBgGA1UECRMRMTAxIFNlY29uZCBTdHJlZXQxDjAMBgNVBBETBTk0MTA1MRcw
FQYDVQQKEw5IYXNoaUNvcnAgSW5jLjFAMD4GA1UEAxM3Q29uc3VsIEFnZW50IENB
IDEyNTkzNjA5NzkwMzcyODI4MDc4MDM4NjQ2MDk0MDQzODk2MzkyNTAeFw0yMzAy
MTkwNzAwMjJaFw0yODAyMTgwNzAwMjJaMBwxGjAYBgNVBAMTEXNlcnZlci5kYzEu
Y29uc3VsMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEz4Lu3sJtHeVk6tCu7+AD
U/KOGKndhdd+jmwSyl6mxOyL99rr14KcrFJs8/B6raVQxqeS3W2SPBqBZxxY9YJ6
/6OB2zCB2DAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsG
AQUFBwMCMAwGA1UdEwEB/wQCMAAwKQYDVR0OBCIEII24u7nJdfAM++X6bVDcAIzo
x3DiR10XyXms2iZcZwrKMCsGA1UdIwQkMCKAILiLGpTUknPMc6MReyyGl/p2hSP4
p4HtSiytl2JBdzYZMEEGA1UdEQQ6MDiCEmNvbnN1bC1zZXJ2ZXIxLWRjMYIRc2Vy
dmVyLmRjMS5jb25zdWyCCWxvY2FsaG9zdIcEfwAAATAKBggqhkjOPQQDAgNIADBF
AiEAnKOLbt+WjGgNW489xQcMXLgHlHNWnqUpFtY89DZhxm4CIHAU8n8nJXCRsTsk
QcaF4mTfNLalIPoQ6kLyn1d7P5d4
-----END CERTIFICATE-----
EOT

cat <<EOT > /etc/consul.d/certs/key_file.pem
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIIolQE5cJbLKxe9OyKGRrj4F37P5TtddL/fC+bWju8+LoAoGCCqGSM49
AwEHoUQDQgAEz4Lu3sJtHeVk6tCu7+ADU/KOGKndhdd+jmwSyl6mxOyL99rr14Kc
rFJs8/B6raVQxqeS3W2SPBqBZxxY9YJ6/w==
-----END EC PRIVATE KEY-----
EOT

cat <<EOT > /etc/consul.d/consul.hcl
server = true
datacenter = "dc1"
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

ports {
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
    ca_file = "/etc/consul.d/certs/ca.pem"
    cert_file = "/etc/consul.d/certs/cert_file.pem"
    key_file = "/etc/consul.d/certs/key_file.pem"

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
