module "label-bastion" {
  source     = "cloudposse/label/null"
  namespace  = var.namespace
  stage      = var.stage
  name       = "bastion"
  attributes = ["public"]
  delimiter  = "-"

  tags = {
    "name" = "bastion-sg"
  }
}

data "curl" "getselfip" {
  http_method = "GET"
  uri         = "https://api.ipify.org"
}
locals {
  selfip = data.curl.getselfip.response

}
module "sg-bastion" {
  source = "cloudposse/security-group/aws"

  attributes = ["primary"]

  # Allow unlimited egress
  allow_all_egress = true

  rules = [
    {
      key         = "ssh"
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["${local.selfip}/32"]
      self        = null
      description = "Allow SSH from anywhere"
    }
  ]

  vpc_id = module.vpc.vpc_id

  context = module.label-bastion.context
}




module "label-private-instances" {
  source     = "cloudposse/label/null"
  namespace  = var.namespace
  stage      = var.stage
  name       = "private-instances"
  attributes = ["private"]
  delimiter  = "-"

  tags = {
    "name" = "private-instances-sg"
  }
}

module "sg-private-instances" {
  source = "cloudposse/security-group/aws"

  attributes = ["primary"]

  # Allow unlimited egress
  allow_all_egress = true

  rules = [
    {
      key         = "all"
      type        = "ingress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [var.cidr_block]
      self        = null
    }
  ]

  vpc_id = module.vpc.vpc_id

  context = module.label-private-instances.context
}







module "label-public-web" {
  source     = "cloudposse/label/null"
  namespace  = var.namespace
  stage      = var.stage
  name       = "web"
  attributes = ["public"]
  delimiter  = "-"

  tags = {
    "name" = "public-web-sg"
  }
}

module "sg-public-web" {
  source = "cloudposse/security-group/aws"

  attributes = ["primary"]

  # Allow unlimited egress
  allow_all_egress = true

  rules = [
    {
      key         = "HTTP"
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [var.cidr_block]
      self        = null
      description = "Allow HTTP from inside the security group"
    },
    {
      key         = "ssh"
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["${local.selfip}/32"]
      self        = null
      description = "Allow SSH from anywhere"
    }
  ]

  vpc_id = module.vpc.vpc_id

  context = module.label-public-web.context
}
