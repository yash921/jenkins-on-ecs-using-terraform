module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  name               = var.app_name
  cidr               = var.vpc_cidr
  azs                = var.availability_zones
  private_subnets    = var.private_subnet_cidrs
  public_subnets     = var.public_subnet_cidrs
  enable_nat_gateway = true
}

