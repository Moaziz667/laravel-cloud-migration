variable "aws_region" {variable "aws_region" {

  description = "AWS region to deploy resources"  description = "AWS region to deploy resources"

  type        = string  type        = string

  default     = "eu-north-1"   default     = "eu-north-1" 

}}



variable "project_name" {variable "vpc_cidr" {

  description = "Name of the project"  description = "CIDR block for the VPC"

  type        = string  type        = string

  default     = "laraveldevops"  default     = "10.0.0.0/16"

}}



variable "public_subnet_cidr" {variable "public_subnet_cidr" {

  description = "CIDR block for the public subnet (EC2)"  description = "CIDR block for the public subnet (EC2)"

  type        = string  type        = string

  default     = "10.0.3.0/24"  default     = "10.1.3.0/24"

}}



variable "private_subnet_cidr" {variable "private_subnet_cidr" {

  description = "CIDR block for the private subnet (EC2)"  description = "CIDR block for the private subnet (EC2)"

  type        = string  type        = string

  default     = "10.0.4.0/24"  default     = "10.1.4.0/24"

}}



variable "key_name" {variable "key_name" {

  description = "Name of the existing EC2 key pair for SSH access"  description = "Name of the existing EC2 key pair for SSH access"

  type        = string  type        = string

  default     = "gitlab-deploy-key"  default     = "gitlab-deploy-key"

}}

variable "db_username" {

variable "instance_type" {  default = "admin"

  description = "EC2 instance type"}

  type        = stringvariable "db_password" {

  default     = "t3.micro"  default = "password"

}}