output "alb_arn" {
  value = aws_lb.gatus_alb.arn
}

output "alb_dns_name" {
  value = aws_lb.gatus_alb.dns_name
}

output "alb_zone_id" {
  value = aws_lb.gatus_alb.zone_id
}

output "http_listener_arn" {
  value = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  value = aws_lb_listener.https.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.target_app.arn
}