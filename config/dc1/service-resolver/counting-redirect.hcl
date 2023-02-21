Kind = "service-resolver"
Name = "counting-redirect"
Redirect {
  Service = "counting"
  Peer    = "dc2"
}