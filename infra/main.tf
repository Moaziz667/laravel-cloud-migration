terraform {
  cloud {
    organization = "Asm_aziz_stage"
    workspaces {
      name = "deploy-infra"
    }
  }
}

# Data source to read RDS outputs from remote state
data "terraform_remote_state" "rds" {
  backend = "remote"

  config = {
    organization = "Asm_aziz_stage"
    workspaces = {
      name = "db-workspace"
    }
  }
}

# Get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Use the latest Ubuntu AMI for the EC2 instance
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical Ubuntu owner ID
}

# Local values for database configuration
locals {
  db_endpoint          = try(data.terraform_remote_state.rds.outputs.db_endpoint, "localhost")
  db_port              = try(data.terraform_remote_state.rds.outputs.db_port, "3306")
  db_name              = try(data.terraform_remote_state.rds.outputs.db_name, "laravel_db")
  db_username          = try(data.terraform_remote_state.rds.outputs.db_username, "admin")
  db_password          = try(data.terraform_remote_state.rds.outputs.db_password, "defaultpass")
  db_security_group_id = try(data.terraform_remote_state.rds.outputs.db_security_group_id, "")

  # Use RDS VPC instead of creating our own
  vpc_id         = try(data.terraform_remote_state.rds.outputs.rds_vpc_id, "")
  vpc_cidr_block = try(data.terraform_remote_state.rds.outputs.rds_vpc_cidr_block, "10.0.0.0/16")
  igw_id         = try(data.terraform_remote_state.rds.outputs.rds_igw_id, "")
}

# Create public subnet for EC2 in the existing RDS VPC
resource "aws_subnet" "public_subnet" {
  vpc_id                  = local.vpc_id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name    = "public-subnet-ec2"
    Project = var.project_name
  }
}

# Create private subnet for EC2 in the existing RDS VPC
resource "aws_subnet" "private_subnet" {
  vpc_id            = local.vpc_id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name    = "private-subnet-ec2"
    Project = var.project_name
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = local.igw_id
  }

  tags = {
    Name    = "public-route-table"
    Project = var.project_name
  }
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security group for EC2 to allow SSH, HTTP, HTTPS, and MySQL access
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allow SSH and HTTP(s) traffic for EC2"
  vpc_id      = local.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-ec2-sg"
    Project = var.project_name
  }
}

# Security group rule to allow EC2 to connect to RDS
resource "aws_security_group_rule" "ec2_to_rds" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = local.db_security_group_id
  security_group_id        = aws_security_group.ec2_sg.id
  description              = "Allow EC2 to connect to RDS"
}

# Create an EC2 instance for the Laravel application
resource "aws_instance" "laravel_app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    db_host     = local.db_endpoint
    db_port     = local.db_port
    db_name     = local.db_name
    db_username = local.db_username
    db_password = local.db_password
  }))

  tags = {
    Name    = "${var.project_name}-app-instance"
    Project = var.project_name
  }
}
