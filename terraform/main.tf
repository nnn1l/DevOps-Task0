module "vpc" {
  source          = "./modules/vpc"
  aws_region      = var.aws_region
  github_username = var.github_username
}

module "security" {
  source          = "./modules/security"
  vpc_id          = module.vpc.vpc_id
  github_username = var.github_username
}

module "alb" {
  source                = "./modules/alb"
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  github_username       = var.github_username
}

module "ecs" {
  source                       = "./modules/ecs"
  public_subnet_ids            = module.vpc.public_subnet_ids
  ecs_tasks_security_group_id  = module.security.ecs_tasks_security_group_id
  frontend_target_group_arn    = module.alb.frontend_target_group_arn
  github_username              = var.github_username
  ecr_image_url                = "125482557355.dkr.ecr.eu-north-1.amazonaws.com/frontend"
}