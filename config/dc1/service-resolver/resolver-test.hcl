Kind           = "service-resolver"
Name           = "resolver"


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