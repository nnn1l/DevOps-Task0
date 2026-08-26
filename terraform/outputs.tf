output "alb_dns_name" {
  description = "Public DNS name of ALB"
  value       = module.alb.alb_dns_name
}