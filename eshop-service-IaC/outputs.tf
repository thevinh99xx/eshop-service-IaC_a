#
# Outputs
#

### EIP1,2 allocatin_id
output "eip_allocation_id" {
  description = "EIPs"
  value       = <<EOT
${module.vpc.public_ip[0]},${module.vpc.public_ip[1]}
EOT
}

### RDS(Mariadb)
output "mariadb_endpoint" {
  description = "The connection endpoint"
  value       = module.data.mariadb_endpoint
}

output "mariadb_user_name" {
  description = "The master username for the database"
  value       = module.data.mariadb_user_name
}

output "mariadb_user_password" {
  description = "The master password for the database"
  value       = module.data.mariadb_user_password
}