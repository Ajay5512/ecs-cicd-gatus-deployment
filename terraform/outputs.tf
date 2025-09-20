# Outputs - Your application access URLs
output "application_url" {
  value       = module.alb.alb_url
  description = "URL to access your application"
}

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
