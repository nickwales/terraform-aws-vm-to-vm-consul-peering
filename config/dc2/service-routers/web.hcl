Kind = "service-router"
Name = "web"
Routes = [
  {
    Match {
      HTTP {
        PathPrefix = "/"
      }
    }
    Destination {
      Service = "web"
    }
  }
]