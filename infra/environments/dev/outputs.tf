output "vpc_id" {
  value = module.networking.vpc_id
}

output "private_app_subnet_ids" {
  value = module.networking.private_app_subnet_ids
}

output "private_data_subnet_ids" {
  value = module.networking.private_data_subnet_ids
}
