output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "target_group_arn" {
  value = module.target_group.target_group_arn
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
