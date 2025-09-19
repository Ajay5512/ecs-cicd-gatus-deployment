# main.tf - Fixed order to avoid circular dependencies

module "vpc" {
  source = "./modules/vpc"
}

module "security_groups" {
  source = "./modules/securitygroups"
  vpc_id = module.vpc.vpc_id
}

# 1. Create DNS zone FIRST (no dependencies)
module "dns_zone" {
  source = "./modules/dns_zone"
}

# 2. Create ACM certificate with validation (depends only on DNS zone)
module "acm" {
  source  = "./modules/acm"
  zone_id = module.dns_zone.zone_id
}

# 3. Create ALB (depends on certificate)
module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security_groups.alb_sg_id
  certificate_arn   = module.acm.certificate_arn
  health_check_path = "/"
}

# 4. Create DNS alias record (depends on ALB)
module "dns_records" {
  source       = "./modules/dns_records"
  zone_id      = module.dns_zone.zone_id
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
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
