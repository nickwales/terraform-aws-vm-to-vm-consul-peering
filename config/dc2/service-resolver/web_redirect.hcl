Kind = "service-resolver"
Name = "counting-redirect"
Redirect {
  Service    = "web"
  Peer = "dc1"
}