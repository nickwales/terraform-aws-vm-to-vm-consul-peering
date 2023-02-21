Kind           = "service-resolver"
Name           = "counting"

ConnectTimeout = "5s"

Failover = {
  "*" = {
    Targets = [
      {
        Service = "web",
        Peer = "dc1"
      }
    ]
  }
}