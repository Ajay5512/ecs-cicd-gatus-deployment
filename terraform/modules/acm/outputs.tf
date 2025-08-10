output "certificate_arn" {
  value = aws_acm_certificate_validation.acm_cert.certificate_arn
}