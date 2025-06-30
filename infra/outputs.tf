output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "k3s_node_public_ip" {
  value = aws_instance.laravel_app.public_ip
}
output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}