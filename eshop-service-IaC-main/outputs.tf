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


