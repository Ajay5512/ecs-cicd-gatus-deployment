resource "aws_route53_record" "alb_alias" {
  zone_id = "Z03197441FOIGRDDOF569"
  name    = "chimwaza.click"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}