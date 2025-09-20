# Outputs - Your application access URLs
output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "ALB DNS name - use this to access your app"
}

output "application_endpoints" {
  value = {
    http_url = "http://${module.alb.alb_dns_name}"
    alb_dns  = module.alb.alb_dns_name
  }
  description = "Application access endpoints"
}