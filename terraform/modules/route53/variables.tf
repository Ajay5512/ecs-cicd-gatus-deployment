
# Output the zone ID for reference
output "zone_id" {
  value = aws_route53_zone.main.zone_id
}

# Output name servers (important for domain configuration)
output "name_servers" {
  value = aws_route53_zone.main.name_servers
}

# Variables
variable "alb_dns_name" {
  type = string
}

variable "alb_zone_id" {
  type = string
}