module "vpc" {
  source = "./modules/vpc"
}

module "security_groups" {
  source = "./modules/securitygroups"
  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source                = "./modules/alb"
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_sg_id
  project_name          = var.project_name
}

module "iam" {
  source = "./modules/iam"
}

module "ecs" {
  source             = "./modules/ecs"
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_sg_id          = module.security_groups.ecs_sg_id
  target_group_arn   = module.alb.target_group_arn
  execution_role_arn = module.iam.execution_role_arn
}
