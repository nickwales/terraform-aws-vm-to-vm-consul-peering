Kind = "service-intentions"
Name = "web"
Sources = [
  {
    Name      = "ingress-gateway"
    Peer      = "dc1"
    Action    = "allow"
  }
]