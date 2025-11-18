terraform {
  cloud {
    organization = "Asm_aziz_stage"
    workspaces {
      name = "db-workspace"
    }
  }
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Generate random password for RDS
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Create VPC for RDS
resource "aws_vpc" "rds_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-rds-vpc"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "rds_igw" {
  vpc_id = aws_vpc.rds_vpc.id

  tags = {
    Name        = "${var.project_name}-rds-igw"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Create public subnets for RDS (Multi-AZ)
resource "aws_subnet" "rds_subnet_1" {
  vpc_id            = aws_vpc.rds_vpc.id
  cidr_block        = var.rds_subnet_1_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = "${var.project_name}-rds-subnet-1"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_subnet" "rds_subnet_2" {
  vpc_id            = aws_vpc.rds_vpc.id
  cidr_block        = var.rds_subnet_2_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name        = "${var.project_name}-rds-subnet-2"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.rds_subnet_1.id, aws_subnet.rds_subnet_2.id]

  tags = {
    Name        = "${var.project_name}-db-subnet-group"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = aws_vpc.rds_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.rds_vpc.cidr_block]
    description = "MySQL/Aurora access from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-rds-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# RDS Parameter Group
resource "aws_db_parameter_group" "main" {
  family = var.db_family
  name   = "${var.project_name}-db-params"

  parameter {
    name  = "innodb_buffer_pool_size"
    value = "{DBInstanceClassMemory*3/4}"
  }

  parameter {
    name  = "max_connections"
    value = "200"
  }

  tags = {
    Name        = "${var.project_name}-db-params"
    Environment = var.environment
    Project     = var.project_name
  }
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-database"
  
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = var.db_storage_type
  storage_encrypted     = true
  
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  
  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.main.name
  
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project_name}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  deletion_protection = var.deletion_protection
  
  copy_tags_to_snapshot = true
  
  tags = {
    Name        = "${var.project_name}-database"
    Environment = var.environment
    Project     = var.project_name
  }
}