output "vpc_id" {
  description = "VPC ID (shared with RDS)"
  value       = local.vpc_id
}

output "public_subnet_id" {
  description = "Public subnet ID for EC2"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "Private subnet ID for EC2"
  value       = aws_subnet.private_subnet.id
}

output "ec2_public_ip" {
  description = "Public IP of the Laravel application EC2 instance"
  value       = aws_instance.laravel_app.public_ip
}

output "ec2_private_ip" {
  description = "Private IP of the Laravel application EC2 instance"
  value       = aws_instance.laravel_app.private_ip
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.laravel_app.id
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
