# Create the hosted zone
resource "aws_route53_zone" "main" {
  name = "chimwaza.click"

  tags = {
    Name = "chimwaza.click"
  }
}

# Create the alias record pointing to ALB
resource "aws_route53_record" "alb_alias" {
  zone_id = aws_route53_zone.main.zone_id # Use the created zone
  name    = "chimwaza.click"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}
