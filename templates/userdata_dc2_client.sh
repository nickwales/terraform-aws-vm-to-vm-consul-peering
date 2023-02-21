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
apt install -y vault consul jq dnsmasq lighttpd unzip awscli net-tools

### Personalize the web service for dc2
echo dc2 > /var/www/html/index.html

### Wait for the server to come up
## Find the server

server_addr=""

while [ -z "${server_addr}" ]
do 
  echo "Server address is: ${server_addr}"
  sleep 5
  server_addr=$(aws --region us-east-1 ec2 describe-instances \
    --filters "Name=tag:Name,Values=server-dc2" "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[PrivateIpAddress]' \
    --output text)
  echo "Server address after the command is: ${server_addr}"
done

## Wait for Consul to come up on the server

consul_status=""
while [ -z "${consul_status}" ]
do
  consul_status=$(curl -s "http://${server_addr}:8500/v1/status/leader")
  sleep 5
  echo "Calling ${server_addr} Consul leader: ${consul_status}"
done

echo "Consul server is up... time to move on"

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

cat <<EOT > /etc/consul.d/consul.hcl
server = false
datacenter = "dc2"
data_dir = "/opt/consul"
client_addr = "0.0.0.0"
advertise_addr = "${INSTANCE_IP}"

ui_config = {
    enabled = true
}

acl {
  enabled = true
  tokens {
    agent = "root"
    default = "root"
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

encrypt = "aPuGh+5UDskRAbkLaXRzFoSOcSM+5vAK+NEYOWHJH7w="

leave_on_terminate = true
connect = {
    enabled = true
}

tls {
  defaults {
    ca_file = "/etc/consul.d/certs/ca.pem"
    verify_incoming = true
    verify_outgoing = true
  }
  internal_rpc {
    verify_server_hostname = true
  }
  grpc {
    verify_incoming = false
  }  
}

auto_encrypt = {
  tls = true
}

addresses = {
  grpc = "0.0.0.0"
  http = "0.0.0.0"
}

retry_join = ["provider=aws tag_key=Name tag_value=server-dc2"]
EOT

## Install Envoy
wget wget https://github.com/envoyproxy/envoy/releases/download/v1.24.1/envoy-1.24.1-linux-x86_64
mv envoy-1.24.1-linux-x86_64 /usr/local/bin/envoy
chmod +x /usr/local/bin/envoy

# Configure systemd-resolved
mkdir -p /etc/systemd/resolved.conf.d
cat <<EOT >> /etc/systemd/resolved.conf.d/consul.conf
[Resolve]
DNS=127.0.0.1:8600
DNSSEC=false
Domains=~consul
EOT

# Configure DNSMASQ
echo "server=/consul/127.0.0.1#8600" > /etc/dnsmasq.d/10-consul

cat <<EOT >> /etc/dnsmasq.conf
port=5353
cache-size=500
max-cache-ttl=2
EOT

systemctl daemon-reload
systemctl enable lighttpd --now
systemctl enable consul --now
# systemctl stop dnsmasq 
# systemctl enable dnsmasq --now
systemctl restart systemd-resolved

sleep 5

#### Configure the gateways
### Ingress

cat <<EOT > /etc/systemd/system/ingress-gateway.service
[Unit]
Description=Consul Ingress Gateway
After=network.target consul.target

[Service]
ExecStart=/usr/bin/consul connect envoy -gateway=ingress -register -service ingress-gateway -admin-bind=127.0.0.1:19008
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOT

###  Terminating

cat <<EOT >> /etc/systemd/system/terminating-gateway.service
[Unit]
Description=Consul Terminating Gateway
After=network.target consul.target

[Service]
ExecStart=/usr/bin/consul connect envoy -gateway=terminating -register -service terminating-gateway -address ${INSTANCE_IP}:8889 -admin-bind=127.0.0.1:19007
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOT

### Mesh

cat <<EOT >> /etc/systemd/system/mesh-gateway.service
[Unit]
Description=Consul Mesh Gateway
After=network.target consul.target

[Service]
ExecStart=/usr/bin/consul connect envoy -gateway=mesh -register -service mesh-gateway -address ${INSTANCE_IP}:8443 -admin-bind=127.0.0.1:19001
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOT

### Start up the gateways

systemctl daemon-reload
systemctl enable ingress-gateway --now
systemctl enable mesh-gateway --now
systemctl enable terminating-gateway --now

#### Create the "web" service
cat <<EOT > /etc/consul.d/web.hcl
service {
  name = "web"
  id   = "web"
  port = 80
  tags = ["primary"]
  checks = [
    {
      http = "http://localhost"
      interval = "5s"
      timeout = "5s"
    }
  ]
}
EOT

#### Deploy the Counting Service
### Service definitions
cat <<EOT > /etc/consul.d/dashboard.hcl
service {
  name = "dashboard"
  port = 9002

  connect {
    sidecar_service {
      proxy {
        upstreams = [
          {
            destination_name = "counting"
            local_bind_port  = 5000
          }
        ]
      }
    }
  }

  check {
    id       = "dashboard-check"
    http     = "http://localhost:9002/health"
    method   = "GET"
    interval = "1s"
    timeout  = "1s"
  }
}
EOT

cat <<EOT > /etc/consul.d/counting.hcl
service {
  name = "counting"
  id = "counting-1"
  port = 9003

  connect {
    sidecar_service {}
  }

  check {
    id       = "counting-check"
    http     = "http://localhost:9003/health"
    method   = "GET"
    interval = "1s"
    timeout  = "1s"
  }
}
EOT

### Get and deploy binaries
wget https://github.com/hashicorp/demo-consul-101/releases/download/0.0.3.1/counting-service_linux_amd64.zip
wget https://github.com/hashicorp/demo-consul-101/releases/download/0.0.3.1/dashboard-service_linux_amd64.zip
unzip counting-service_linux_amd64.zip -d /usr/local/bin/
unzip dashboard-service_linux_amd64.zip -d /usr/local/bin/

### Manage services and sidecars with systemd
##  Dashboard service
cat <<EOT > /etc/systemd/system/dashboard.service
[Unit]
Description=Dashboard Service
After=network.target consul.target

[Service]
Environment=PORT=9002 
Environment=COUNTING_SERVICE_URL="http://localhost:5000"
ExecStart=/usr/local/bin/dashboard-service_linux_amd64
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOT

##  Dashboard sidecar proxy
cat <<EOT > /etc/systemd/system/dashboard-sidecar-proxy.service
[Unit]
Description="Dashboard sidecar proxy service"
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/consul connect envoy -sidecar-for dashboard -admin-bind 127.0.0.1:19006
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOT

## Counting Service
cat <<EOT > /etc/systemd/system/counting.service
[Unit]
Description=Counting Service
After=network.target consul.target

[Service]
Environment=PORT=9003
ExecStart=/usr/local/bin/counting-service_linux_amd64
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOT

## Counting sidecar service 
cat <<EOT > /etc/systemd/system/counting-sidecar-proxy.service
[Unit]
Description="Counting sidecar proxy service"
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/consul connect envoy -sidecar-for counting-1 \
  -admin-bind 127.0.0.1:19005
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOT

consul reload
systemctl daemon-reload
systemctl enable counting.service --now
systemctl enable dashboard.service --now
systemctl enable counting-sidecar-proxy.service --now
systemctl enable dashboard-sidecar-proxy.service --now

