# MVP single instance deployment
module "bastion" {
  source      = "./modules/bastion"
  project_id  = var.project_id
  environment = var.environment
}

# VPC deployment
module "vpc" {
  depends_on         = [module.bastion]
  source             = "./modules/vpc"
  project            = var.project
  project_id         = var.project_id
  region             = var.region
  environment        = var.environment
  availability_zones = var.availability_zones
  vpc_cidr           = var.vpc_cidr
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
}

module "securitygroups" {
  depends_on = [module.vpc]
  source     = "./modules/securitygroups"
  project_id = var.project_id
  vpc_id     = module.vpc.vpc_id
}

# ALB deployment
module "alb" {
  depends_on         = [module.vpc]
  source             = "./modules/alb"
  project            = var.project
  project_id         = var.project_id
  region             = var.region
  environment        = var.environment
  availability_zones = var.availability_zones
  private_subnets    = module.vpc.private_subnet_ids
  public_subnets     = module.vpc.public_subnet_ids
  vpc_id             = module.vpc.vpc_id
  allow_http         = module.securitygroups.allow_http
}

# ASG deployment
module "asg" {
  depends_on             = [module.alb]
  source                 = "./modules/asg"
  project                = var.project
  project_id             = var.project_id
  region                 = var.region
  environment            = var.environment
  availability_zones     = var.availability_zones
  private_subnets        = module.vpc.private_subnet_ids
  instance_type          = var.instance_type
  instance_count_min     = var.instance_count_min
  instance_count_max     = var.instance_count_max
  instance_count_desired = var.instance_count_desired
  main_alb_tg_arn        = module.alb.main_alb_tg_arn
  allow_http             = module.securitygroups.allow_http
}
