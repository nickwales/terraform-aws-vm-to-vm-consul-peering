Kind = "ingress-gateway"
Name = "ingress-gateway"

Listeners = [
 {
   Port = 8889
   Protocol = "tcp"
   Services = [
     {
       Name = "dashboard"
       #Hosts = ["*"]   
     }
   ]
 },
 {
   Port = 8890
   Protocol = "tcp"
   Services = [
     {
       Name = "web"
#       Hosts = ["*"]   
     }
   ]
 } 
]