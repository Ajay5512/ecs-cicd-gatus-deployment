
output "certificate_arn" {
  value = aws_acm_certificate_validation.acm_cert.certificate_arn
}

# Add this variable to receive zone_id from route53 module
variable "zone_id" {
  type        = string
  description = "Route53 hosted zone ID"
}