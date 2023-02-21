Kind           = "service-resolver"
Name           = "web-failover"
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