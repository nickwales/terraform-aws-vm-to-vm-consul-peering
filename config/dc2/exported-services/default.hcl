Kind = "exported-services"
Name = "default"
Services = [
  {
    Name = "web"
    Consumers = [
      {
        Peer = "dc1"
      }
    ]
  },
  {
    Name = "counting"
    Consumers = [
      {
        Peer = "dc1"
      }
    ]
  }  
]
