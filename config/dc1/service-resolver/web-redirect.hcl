Kind = "service-resolver"
Name = "web-redirect"
Redirect {
  Service = "web"
  Peer    = "dc2"
}