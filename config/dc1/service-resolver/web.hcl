Kind           = "service-resolver"
Name           = "web"
ConnectTimeout = "5s"

Failover = {
  "*" = {
    Targets = [
      {
        Service = "web"
      },      
      {
        Service = "web",
        Peer = "dc2"
      }
    ]
  }
}

## This breaks the consul client where the ingress gateway is deployed