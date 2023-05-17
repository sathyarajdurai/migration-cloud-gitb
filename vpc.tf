module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.1"

  name = "migration-vpc"
  cidr = var.vpc_cidr

  azs              = slice(data.aws_availability_zones.available.names, 0, var.number_of_azs)
  private_subnets  = [for i, v in local.availability-zones : cidrsubnet(local.private_subnet_cidr, 4, i)]
  database_subnets = [for i, v in local.availability-zones : cidrsubnet(local.database_subnet_cidr, 1, i)]
  public_subnets   = [for i, v in local.availability-zones : cidrsubnet(local.public_subnet_cidr, 1, i)]
  # database_subnet_group_name = var.database_subnetgrp_name
  enable_nat_gateway = true
  #enable_vpn_gateway = true
  single_nat_gateway = true

  enable_flow_log = true
  flow_log_destination_arn = aws_s3_bucket.vpc_logs.arn
  flow_log_destination_type = "s3"
  create_flow_log_cloudwatch_iam_role = false

  #default_security_group_ingress =[{"from_port": "443","to_port": "443","protocol": "tcp","cidr_blocks": "0.0.0.0/0"}]
  #default_security_group_egress = [{"from_port": "0","to_port": "0","protocol": "tcp","cidr_blocks": "0.0.0.0/0"}]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

#[for i, v in ["eu-west-1a", "eu-west-1b"] : cidrsubnet("10.0.16.0/20", 4, i)]
