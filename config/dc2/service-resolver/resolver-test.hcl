Kind           = "service-resolver"
Name           = "resolver"

Redirect {
  Service    = "web"
  Datacenter = "dc1"
}

# Failover = {
#   "*" = {
#     Targets = [
#       {
#         Service = "web",
#         Peer = "dc2",
#       }
#     ]
#   }
# }