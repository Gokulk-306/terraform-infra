variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the certificate"
  type        = string
}

output "certificate_arn" {
  description = "ARN of the certificate"
  value       = aws_acm_certificate.this.arn
}

output "dns_validation_records" {
  description = "DNS validation records for manual setup in GoDaddy"
  value = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
}