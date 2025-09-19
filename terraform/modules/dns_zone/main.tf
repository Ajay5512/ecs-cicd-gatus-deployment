# modules/dns_zone/main.tf
# This module ONLY creates the hosted zone - no dependencies

resource "aws_route53_zone" "main" {
  name = "chimwaza.click"

  tags = {
    Name = "chimwaza.click"
  }
}

output "zone_id" {
  value = aws_route53_zone.main.zone_id
}

output "name_servers" {
  value = aws_route53_zone.main.name_servers
}