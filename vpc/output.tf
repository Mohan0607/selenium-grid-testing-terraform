output "public_subnets" {
  value = aws_subnet.bastion[*].id
}

output "Private_subnet" {
  value = aws_subnet.private_egress[*].id
}

output "vpc_id" {
  value = aws_vpc.main.id
}