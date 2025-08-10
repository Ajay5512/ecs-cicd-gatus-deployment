variable "publicnacl_config" {
  type = list(object({
    rule_number = number
    egress      = bool
    protocol    = string
    action      = string
    cidr_block  = string
    from_port   = number
    to_port     = number
  }))
  #Allowing HTTP in
  default = [{
    rule_number = 10
    egress      = false
    protocol    = "tcp"
    action      = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 80
    to_port     = 80
    },
    # Allowing HTTPS in
    {
      rule_number = 20
      egress      = false
      protocol    = "tcp"
      action      = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 443
      to_port     = 443
    },
    # Allowing all traffic in from the private subnets
    {
      rule_number = 30
      egress      = false
      protocol    = "-1"
      action      = "allow"
      cidr_block  = "10.0.0.128/25"
      from_port   = 0
      to_port     = 0
    },
    #outbound traffic directed to private subnets (Hosting ECS)
    {
      rule_number = 110
      egress      = true
      protocol    = "tcp"
      action      = "allow"
      cidr_block  = "10.0.0.128/25"
      from_port   = 8080
      to_port     = 8080
    },
    # Deny outbound traffic to my private subnet (with a higher rule number)
    # Feels a bit un-necessary but for tigther security can use
    # {
    #   rule_number = 115
    #   egress = true
    #   protocol = "-1"
    #   action = "deny"
    #   cidr_block = "10.0.0.128/25"
    #   from_port = 0
    #   to_port = 0

    # },
    #outbound traffic directed back to internet
    {
      rule_number = 120
      egress      = true
      protocol    = "-1"
      action      = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
    }

  ]
}

