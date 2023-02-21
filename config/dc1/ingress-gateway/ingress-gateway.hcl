Kind = "ingress-gateway"
Name = "ingress-gateway"

Listeners = [
 {
   Port = 8888
   Protocol = "tcp"
   Services = [
     {
       Name = "dashboard"       
     }
   ]
 },
 {
   Port = 8890
   Protocol = "tcp"
   Services = [
     {
       Name = "web"       
     }
   ]
  } 
#  {
#    Port = 8891
#    Protocol = "tcp"
#    Services = [
#      {
#        Name = "web-redirect"       
#      }
#    ]
#  }
]