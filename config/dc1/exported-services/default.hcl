Kind = "exported-services"
Name = "default"
Services = [
  # {
  #   Name = "web"
  #   Consumers = [
  #     {
  #       Peer = "dc2"
  #     }
  #   ]
  # },
  {
    Name = "counting"
    Consumers = [
      {
        Peer = "dc2"
      }
    ]
  }  
]