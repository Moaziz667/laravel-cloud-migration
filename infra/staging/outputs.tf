output "staging_ec2_public_ip" {
  description = "Public IP address of the staging EC2 instance"
  value       = aws_instance.app.public_ip
}

output "staging_ec2_private_ip" {
  description = "Private IP address of the staging EC2 instance"
  value       = aws_instance.app.private_ip
}

output "staging_db_endpoint" {
  description = "Connection endpoint for the staging database"
  value       = aws_db_instance.staging.address
}

output "staging_db_port" {
  description = "Port the staging database listens on"
  value       = aws_db_instance.staging.port
}

output "staging_db_name" {
  description = "Database name provisioned for staging"
  value       = aws_db_instance.staging.db_name
}

output "staging_db_username" {
  description = "Master username for the staging database"
  value       = aws_db_instance.staging.username
  sensitive   = true
}

output "staging_db_password" {
  description = "Master password for the staging database"
  value       = random_password.db.result
  sensitive   = true
}
