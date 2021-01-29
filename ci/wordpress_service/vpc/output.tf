output "private_route_table_ids" {
    value = module.vpc.private_route_table_ids
}

output "vpc_id" {
    value = module.vpc.vpc_id
}
output "public_subnet_cidr_blocks" {
    value = module.vpc.public_subnet_cidr_blocks
}
output "private_subnet_cidr_blocks" {
    value = module.vpc.private_subnet_cidr_blocks
}

output "private_subnet_ids" {
    value = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
    value = module.vpc.public_subnet_ids
}