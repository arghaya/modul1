module "vpc" {
  source    = "cloudposse/vpc/aws"
  namespace = var.namespace
  stage     = var.stage
  name      = var.name

  ipv4_primary_cidr_block = var.cidr_block

  assign_generated_ipv6_cidr_block = true
}

locals {
  public_cidr_block  = cidrsubnet(module.vpc.vpc_cidr_block, 5, 0)
  private_cidr_block = cidrsubnet(module.vpc.vpc_cidr_block, 5, 1)
}

module "public_subnets" {
  source = "cloudposse/multi-az-subnets/aws"

  namespace           = var.namespace
  stage               = var.stage
  name                = var.name
  availability_zones  = ["us-east-1a", "us-east-1b"]
  vpc_id              = module.vpc.vpc_id
  cidr_block          = local.public_cidr_block
  type                = "public"
  igw_id              = module.vpc.igw_id
  nat_gateway_enabled = "true"
}


module "private_subnets" {
  source = "cloudposse/multi-az-subnets/aws"

  namespace          = var.namespace
  stage              = var.stage
  name               = var.name
  availability_zones = ["us-east-1a", "us-east-1b"]
  vpc_id             = module.vpc.vpc_id
  cidr_block         = local.private_cidr_block
  type               = "private"
  az_ngw_ids         = module.public_subnets.az_ngw_ids
}

output "private_az_subnet_ids" {
  value = module.private_subnets.az_subnet_ids
}

output "public_az_subnet_ids" {
  value = module.public_subnets.az_subnet_ids
}