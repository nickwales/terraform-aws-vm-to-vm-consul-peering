Kind      = "service-intentions"
Name      = "counting"

Sources = [
  {
    Name   = "dashboard"
    Peer   = "dc1"
    Action = "allow"
  }
]