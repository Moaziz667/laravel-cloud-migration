output "vpc_id" {
  description = "VPC ID (shared with RDS)"
  value = local.vpc_id
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

# Database outputs from RDS remote state
output "db_endpoint" {
  description = "Database endpoint from RDS workspace"
  value       = local.db_endpoint
}

output "db_port" {
  description = "Database port from RDS workspace"
  value       = local.db_port
}

output "db_name" {
  description = "Database name from RDS workspace"
  value       = local.db_name
}

output "db_username" {
  description = "Database username from RDS workspace"
  value       = local.db_username
  sensitive   = true
}

output "db_password" {
  description = "Database password from RDS workspace"
  value       = local.db_password
  sensitive   = true
}

output "db_connection_string" {
  description = "Database connection string from RDS workspace"
  value       = try(data.terraform_remote_state.rds.outputs.db_connection_string, "")
  sensitive   = true
}

output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}