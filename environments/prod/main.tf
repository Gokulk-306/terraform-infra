# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

# Security Group Module
module "security_group" {
  source = "../../modules/security-group"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

# ACM Module
module "acm" {
  source = "../../modules/acm"

  project_name = var.project_name
  domain_name  = var.domain_name
}

# EC2 Module
module "ec2" {
  source = "../../modules/ec2"

  project_name      = var.project_name
  key_name          = var.key_name
  security_group_id = module.security_group.ec2_security_group_id
}

# ALB Module
module "alb" {
  source = "../../modules/alb"

  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_id  = module.security_group.alb_security_group_id
  certificate_arn    = module.acm.certificate_arn
}

# Auto Scaling Module
module "autoscaling" {
  source = "../../modules/autoscaling"

  project_name        = var.project_name
  private_subnet_ids  = module.vpc.private_subnet_ids
  target_group_arn    = module.alb.target_group_arn
  launch_template_id  = module.ec2.launch_template_id
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
}

# CloudWatch Module
module "cloudwatch" {
  source = "../../modules/cloudwatch"

  project_name            = var.project_name
  alert_email             = var.alert_email
  autoscaling_group_name  = module.autoscaling.autoscaling_group_name
  alb_full_name           = module.alb.alb_dns_name
}