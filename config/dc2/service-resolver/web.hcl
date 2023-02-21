Kind           = "service-resolver"
Name           = "web"
ConnectTimeout = "5s"

Failover = {
  "*" = {
    Targets = [
      {
        Service = "web",
        Peer = "dc2",
      }
    ]
  }
}