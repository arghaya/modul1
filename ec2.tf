data "aws_caller_identity" "current" {}


data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}


output "ami_id" {
  value = data.aws_ami.ubuntu.id
}

resource "aws_eip" "bastion" {
  instance = module.instance-bastion.id
  vpc      = true

  depends_on=[module.instance-bastion]
}


module "instance-bastion" {
  source          = "cloudposse/ec2-instance/aws"
  ssh_key_pair    = module.ssh_key_pair.key_name
  instance_type   = "t2.micro"
  vpc_id          = module.vpc.vpc_id
  security_groups = ["${module.sg-bastion.id}"]
  subnet          = module.public_subnets.az_subnet_ids["us-east-1a"]
  namespace       = var.namespace
  stage           = var.stage
  name            = "bastion-instance"
  ami             = data.aws_ami.ubuntu.id
  ami_owner       = "099720109477"

}



module "instance-jenkins" {
  source          = "cloudposse/ec2-instance/aws"
  ssh_key_pair    = module.ssh_key_pair.key_name
  instance_type   = "t2.micro"
  vpc_id          = module.vpc.vpc_id
  security_groups = ["${module.sg-private-instances.id}"]
  subnet          = module.private_subnets.az_subnet_ids["us-east-1a"]
  namespace       = var.namespace
  stage           = var.stage
  name            = "jenkins-instance"
  ami             = data.aws_ami.ubuntu.id
  ami_owner       = "099720109477"
}

resource "aws_eip" "app" {
  instance = module.instance-app.id
  vpc      = true

  depends_on=[module.instance-app]
}

module "instance-app" {
  source          = "cloudposse/ec2-instance/aws"
  ssh_key_pair    = module.ssh_key_pair.key_name
  instance_type   = "t2.micro"
  vpc_id          = module.vpc.vpc_id
  security_groups = ["${module.sg-public-web.id}"]
  subnet          = module.public_subnets.az_subnet_ids["us-east-1b"]
  namespace       = var.namespace
  stage           = var.stage
  name            = "app-instance"
  ami             = data.aws_ami.ubuntu.id
  ami_owner       = "099720109477"
}