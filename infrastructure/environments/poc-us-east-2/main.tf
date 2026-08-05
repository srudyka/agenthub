provider "aws" {
  region = var.region
  default_tags { tags = { Environment = "dev", Purpose = "agenthub-spike", Owner = "srudyka", ManagedBy = "terraform" } }
}

data "aws_availability_zones" "available" { state = "available" }

locals {
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  subnets         = cidrsubnets(var.vpc_cidr, 4, 4, 4, 4)
  public_subnets  = slice(local.subnets, 0, 2)
  private_subnets = slice(local.subnets, 2, 4)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  name                 = "agenthub-spike"
  cidr                 = var.vpc_cidr
  azs                  = local.azs
  public_subnets       = local.public_subnets
  private_subnets      = local.private_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
}

output "vpc_id" { value = module.vpc.vpc_id }
output "private_subnet_ids" { value = module.vpc.private_subnets }
