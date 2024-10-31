#
# Outputs
#

## RDS(Mariadb)
output "mariadb_endpoint" {
  description = "The connection endpoint"
  value       = element(split(":", aws_db_instance.service.endpoint),0)
}

output "mariadb_user_name" {
  description = "The master username for the database"
  value       = aws_db_instance.service.username
}

output "mariadb_user_password" {
  description = "The master password for the database"
  value       = random_string.password.result
}
