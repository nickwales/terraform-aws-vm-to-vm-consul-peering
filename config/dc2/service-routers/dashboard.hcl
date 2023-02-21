Kind = "service-router"
Name = "dashboard"
Routes = [
  {
    Match {
      HTTP {
        PathPrefix = "/"
      }
    }
    Destination {
      Service = "dashboard"
    }
  }
]