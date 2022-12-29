provider "aws" {
  region = "ap-northeast-2"
}

# terraform.tfvars에 정의된 variable 정보를 가져와서 초기화를 진행한다
variable "vpc_name" {
  description = "생성되는 vpc 이름"
  type        = string
  default     = "default_vpc"
}

locals {
  common_tags = {
    project = "terraform-study"
    owner   = "brian"
  }
}

########################################
#                                      #
#             output 정의              #
#                                      #
########################################

output "vpc_name" {
  description = "vpc의 이름"
  value       = module.vpc.name
}

output "vpc_id" {
  description = "vpc의 id 정보"
  value       = module.vpc.id
}

output "vpc_cidr" {
  description = "vpc에 할당되는 cidr block 정보"
  value       = module.vpc.cidr_block
}

output "subnet_groups" {
  description = "subnet 그룹의 정보. public, private를 모두 포함한다"
  value = {
    public  = module.subnet_group__public
    private = module.subnet_group__private
  }
}

########################################
#                                      #
#             module 정의              #
#                                      #
########################################

module "vpc" {
  source  = "tedilabs/network/aws//modules/vpc"
  version = "0.24.0"

  name       = var.vpc_name
  cidr_block = "20.0.0.0/16"

  internet_gateway_enabled = true

  dns_hostnames_enabled = true
  dns_support_enabled   = true

  tags = local.common_tags
}

# public subnet group
module "subnet_group__public" {
  source  = "tedilabs/network/aws//modules/subnet-group"
  version = "0.24.0"

  name                    = "${module.vpc.name}-public"
  vpc_id                  = module.vpc.id
  map_public_ip_on_launch = true

  subnets = {
    "${module.vpc.name}-public-001/az1" = {
      cidr_block           = "20.0.0.0/24"
      availability_zone_id = "apne2-az1"
    }

    "${module.vpc.name}-public-002/az3" = {
      cidr_block          = "20.0.1.0/24"
      avalibility_zone_id = "apne2-az3"
    }
  }

  tags = local.common_tags
}

module "subnet_group__private" {
  source  = "tedilabs/network/aws//modules/subnet-group"
  version = "0.24.0"

  name                    = "${module.vpc.name}-private"
  vpc_id                  = module.vpc.id
  map_public_ip_on_launch = false

  subnets = {
    "${module.vpc.name}-private-001/az1" = {
      cidr_block          = "20.0.10.0/24"
      avalibility_zone_id = "apne2-az1"
    }

    "${module.vpc.name}-private-002/az3" = {
      cidr_block          = "20.0.11.0/24"
      avalibility_zone_id = "apne2-az3"
    }
  }

  tags = local.common_tags
}

module "route_table__public" {
  source  = "tedilabs/network/aws//modules/route-table"
  version = "0.24.0"

  name   = "${module.vpc.name}-public"
  vpc_id = module.vpc.id

  subnets = module.subnet_group__public.ids

  ipv4_routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.vpc.internet_gateway_id
    }
  ]

  tags = local.common_tags
}

module "route_table__private" {
  source  = "tedilabs/network/aws//modules/route-table"
  version = "0.24.0"

  name   = "${module.vpc.name}-private"
  vpc_id = module.vpc.id

  subnets = module.subnet_group__private.ids

  ipv4_routes = []

  tags = local.common_tags
}
