Kind = "service-intentions"
Name = "web"
Sources = [
  {
    Name      = "ingress-gateway"
#    Peer      = "dc2"
    Action    = "allow"
  }
]