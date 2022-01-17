provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "base-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
  }
}

module "vpc_security_groups" {
  source               = "./modules/security-groups"
  vpc_id               = module.vpc.vpc_id
  cicd_public_subnets = module.vpc.public_subnets_cidr_blocks
}


module "ec2" {
  source                   = "./modules/ec2"
  security_group = module.vpc_security_groups.instance_security_group
  subnet_id                = module.vpc.public_subnets[0]
  key_name                 = "default"
  instance_type            = "t3.small"
  ami                      = "ami-07d02ee1eeb0c996c"
  cluster_name             = "arielly-test"
  cluster_description      = "Arielly Test"
  cluster_intention        = "cooperative"
  cluster_password         = "123456"
  max_players              = "6"
  cluster_token_parameter  = "/cluster/dont_starve_together/token"
}
