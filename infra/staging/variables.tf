variable "aws_region" {
  description = "AWS region to deploy staging infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Label used for tagging staging resources"
  type        = string
  default     = "laraops-staging"
}

variable "instance_type" {
  description = "EC2 instance type for the staging application host"
  type        = string
  default     = "t3.micro"
}

variable "db_instance_class" {
  description = "Instance size for the staging database"
  type        = string
  default     = "db.t3.micro"
}

variable "db_engine" {
  description = "Database engine for staging"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "db_name" {
  description = "Staging database name"
  type        = string
  default     = "laraops_staging"
}

variable "db_username" {
  description = "Master username for the staging database"
  type        = string
  default     = "staging_admin"
}

variable "ssh_key_name" {
  description = "Name of the EC2 key pair to attach to the staging instance"
  type        = string
}
