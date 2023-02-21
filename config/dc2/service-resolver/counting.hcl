Kind           = "service-resolver"
Name           = "counting"
ConnectTimeout = "2s"

Failover = {
  "*" = {
    Targets = [
      {
        Service = "counting",
        Peer = "dc1"
      }
    ]
  }
}