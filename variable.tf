variable list {
  default = [ "requester_vpc", "accepter_vpc"]
}


variable map {
  default = {
    requester_vpc = "10.0.0.0/18"
    accepter_vpc = "10.1.0.0/18"
    
  }
}
