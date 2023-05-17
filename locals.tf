locals {
  availability-zones = slice(data.aws_availability_zones.available.names, 0, var.number_of_azs)

  public_subnet_cidr   = cidrsubnet(var.vpc_cidr, 7, 8)
  private_subnet_cidr  = cidrsubnet(var.vpc_cidr, 5, 3)
  database_subnet_cidr = cidrsubnet(local.private_subnet_cidr, 3, 2)
}

