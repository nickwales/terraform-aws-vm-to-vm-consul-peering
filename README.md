## Peer the clusters

### Create Certificates

```
consul tls ca create -days=3650
consul tls cert create -server -dc=dc1 -additional-dnsname=server.dc1.consul -days=1825
consul tls cert create -server -dc=dc2 -additional-dnsname=consul-server1-dc2 -days=1825
chmod 644 *
```

Documentation:
https://developer.hashicorp.com/consul/api-docs/peering#establish-a-peering-connection
https://developer.hashicorp.com/consul/docs/connect/cluster-peering/create-manage-peering#create-a-peering-token

### On the "ingress" cluster 
https://developer.hashicorp.com/consul/commands/peering/establish
`consul peering generate-token -name egress`

### On the "egress" cluster
`consul peering establish -name ingress -peering-token <generated_token_from_previous_command>`

#### API
`curl --request POST --data '{"Peername":"egress"}' --url http://localhost:8500/v1/peering/token`

add `"Peername": "ingress"` to the json file and on the egress cluster run:

`curl --request POST --data @peering_token.json http://127.0.0.1:8500/v1/peering/establish`

### Test the web service can be reached from the ingress cluster
curl 'localhost:8500/v1/health/service/web?peer=egress'



##### Apply Configurations

### DC1

```
# Gateways
consul config write config/dc1/ingress-gateway/ingress-gateway.hcl
consul config write config/dc1/terminating-gateway/terminating-gateway.hcl
consul config write config/dc1/mesh/mesh.hcl

# Intentions
consul config write config/dc1/intentions/default.hcl
consul config write config/dc1/intentions/web.hcl
consul config write config/dc1/intentions/dashboard.hcl
consul config write config/dc1/intentions/counting.hcl

# Service Defaults
consul config write config/dc1/service-defaults/web.hcl
consul config write config/dc1/service-defaults/counting.hcl
consul config write config/dc1/service-defaults/dashboard.hcl
consul config write config/dc1/service-defaults/ingress-gateway.hcl

# Exported Services
consul config write config/dc1/exported-services/default.hcl
```

### DC2
```
# Gateways
consul config write config/dc2/ingress-gateway/ingress-gateway.hcl
consul config write config/dc2/terminating-gateway/terminating-gateway.hcl
consul config write config/dc2/mesh/mesh.hcl

# Intentions
consul config write config/dc2/intentions/default.hcl
consul config write config/dc2/intentions/web.hcl
consul config write config/dc2/intentions/dashboard.hcl
consul config write config/dc2/intentions/counting.hcl

# Defaults
consul config write config/dc2/service-defaults/web.hcl
consul config write config/dc2/service-defaults/counting.hcl
consul config write config/dc2/service-defaults/dashboard.hcl

# Exported Services
consul config write config/dc2/exported-services/default.hcl
```