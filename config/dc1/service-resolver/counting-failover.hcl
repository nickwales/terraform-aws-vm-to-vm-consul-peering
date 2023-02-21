Kind           = "service-resolver"
Name           = "counting-failover"
ConnectTimeout = "3s"

Failover = {

  "*" = {
    Targets = [
      {
        Service = "counting",
      },
      {
        Service = "counting",
        Peer = "dc2"
      }
    ]
  }
}