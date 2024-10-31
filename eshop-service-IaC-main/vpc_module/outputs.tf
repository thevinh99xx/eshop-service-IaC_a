
## EIP1,2
output "public_ip" {
  description = "Contains the public IP address"
  value       = [aws_eip.eip1.id, aws_eip.eip2.id]
}

## VPC_ID
output "vpc_id" {
  value = aws_vpc.service.id
}

## Private_subnet_id
output "private_subnet_id" {
  value = [aws_subnet.private.*.id[0], aws_subnet.private.*.id[1]]
}

## Service Nat GW IP for var
# output "nat_gateway_ip" {
#   value = aws_eip.nat.public_ip
# }