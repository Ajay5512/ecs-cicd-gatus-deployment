# modules/dns_records/main.tf
# This module creates DNS records that depend on other resources

resource "aws_route53_record" "alb_alias" {
  zone_id = var.zone_id
  name    = "chimwaza.click"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

variable "zone_id" {
  type        = string
  description = "Route53 hosted zone ID"
}

variable "alb_dns_name" {
  type = string
}

variable "alb_zone_id" {
  type = string
}