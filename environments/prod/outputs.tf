output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.alb.alb_dns_name
}

output "dns_validation_records" {
  description = "DNS validation records for SSL certificate"
  value       = module.acm.dns_validation_records
}