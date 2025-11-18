variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1" 
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet (EC2)"
  type        = string
  default     = "10.1.3.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet (EC2)"
  type        = string
  default     = "10.1.4.0/24"
}

variable "key_name" {
  description = "Name of the existing EC2 key pair for SSH access"
  type        = string
  default     = "gitlab-deploy-key"
}
variable "db_username" {
  default = "admin"
}
variable "db_password" {
  default = "password"
}