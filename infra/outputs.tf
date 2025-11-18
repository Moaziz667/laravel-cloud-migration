output "vpc_id" {output "vpc_id" {

  description = "VPC ID (shared with RDS)"  description = "VPC ID (shared with RDS)"

  value       = local.vpc_id  value = local.vpc_id

}}



output "public_subnet_id" {output "public_subnet_id" {

  description = "Public subnet ID for EC2"  value = aws_subnet.public_subnet.id

  value       = aws_subnet.public_subnet.id}

}

output "private_subnet_id" {

output "private_subnet_id" {  value = aws_subnet.private_subnet.id

  description = "Private subnet ID for EC2"}

  value       = aws_subnet.private_subnet.id

}output "k3s_node_public_ip" {

  value = aws_instance.laravel_app.public_ip

output "ec2_public_ip" {}

  description = "Public IP of the Laravel application EC2 instance"

  value       = aws_instance.laravel_app.public_ip# Database outputs from RDS remote state

}output "db_endpoint" {

  description = "Database endpoint from RDS workspace"

output "ec2_private_ip" {  value       = local.db_endpoint

  description = "Private IP of the Laravel application EC2 instance"}

  value       = aws_instance.laravel_app.private_ip

}output "db_port" {

  description = "Database port from RDS workspace"

output "ec2_instance_id" {  value       = local.db_port

  description = "EC2 instance ID"}

  value       = aws_instance.laravel_app.id

}output "db_name" {

  description = "Database name from RDS workspace"

# Database outputs from RDS remote state  value       = local.db_name

output "db_endpoint" {}

  description = "Database endpoint from RDS workspace"

  value       = local.db_endpointoutput "db_username" {

}  description = "Database username from RDS workspace"

  value       = local.db_username

output "db_port" {  sensitive   = true

  description = "Database port from RDS workspace"}

  value       = local.db_port

}output "db_password" {

  description = "Database password from RDS workspace"

output "db_name" {  value       = local.db_password

  description = "Database name from RDS workspace"  sensitive   = true

  value       = local.db_name}

}

output "db_connection_string" {

output "db_username" {  description = "Database connection string from RDS workspace"

  description = "Database username from RDS workspace"  value       = try(data.terraform_remote_state.rds.outputs.db_connection_string, "")

  value       = local.db_username  sensitive   = true

  sensitive   = true}

}

output "rds_endpoint" {

output "db_password" {  value = aws_db_instance.default.endpoint

  description = "Database password from RDS workspace"}
  value       = local.db_password
  sensitive   = true
}

output "db_connection_string" {
  description = "Database connection string from RDS workspace"
  value       = try(data.terraform_remote_state.rds.outputs.db_connection_string, "")
  sensitive   = true
}