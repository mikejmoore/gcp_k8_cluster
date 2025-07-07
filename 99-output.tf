output "vpc_cider" {
  value = var.vpc_cidr
}

output "subnet_calc" {
  value = local.subnets_calc
}

output "subnets" {
  value = local.subnets
}

output "private_subnets" {
  value = lookup(local.subnets, "private", 0)
}


output "secondary_ranges" {
  value = module.vpc.subnets_secondary_ranges
}

output "subnet-1" {
  value = module.vpc.subnets
}