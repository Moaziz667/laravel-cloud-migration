
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

# Local values for database configuration
locals {
  db_endpoint = try(data.terraform_remote_state.rds.outputs.db_endpoint, "localhost")
  db_port     = try(data.terraform_remote_state.rds.outputs.db_port, "3306")
  db_name     = try(data.terraform_remote_state.rds.outputs.db_name, "laravel_db")
  db_username = try(data.terraform_remote_state.rds.outputs.db_username, "admin")
  db_password = try(data.terraform_remote_state.rds.outputs.db_password, "defaultpass")
  db_security_group_id = try(data.terraform_remote_state.rds.outputs.db_security_group_id, "")
  
  # Use RDS VPC instead of creating our own
  vpc_id = try(data.terraform_remote_state.rds.outputs.rds_vpc_id, "")
  vpc_cidr_block = try(data.terraform_remote_state.rds.outputs.rds_vpc_cidr_block, "10.1.0.0/16")
}

# Use the existing RDS VPC (don't create a new one)
# Create subnets in the existing RDS VPC for EC2
resource "aws_subnet" "public_subnet" {
  vpc_id                  = local.vpc_id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "public-subnet-ec2"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = local.vpc_id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "private-subnet-ec2"
  }
}

# Get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Use the existing Internet Gateway from RDS VPC
# No need to create a new IGW, use the one from RDS

# Create a public subnet with automatic public IP assignment
resource "aws_subnet" "public_subnet" {
  vpc_id                  = local.vpc_id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "public-subnet"
  }
}

# Create a private subnet in the VPC
resource "aws_subnet" "private_subnet" {
  vpc_id            = local.vpc_id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "private-subnet"
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = try(data.terraform_remote_state.rds.outputs.rds_igw_id, "")
  }

  tags = {
    Name = "public-route-table"
  }
}


# Associate the public subnet with the public route table
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security group to allow SSH, HTTP, HTTPS, and MySQL access
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Allow SSH and HTTP(s) traffic"
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

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    description = "Allow MySQL access within security group"
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Specific rule for MySQL/RDS connection
  egress {
    description = "MySQL to RDS"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_block]
  }

  tags = {
    Name = "ec2-sg"
  }
}

# Create an EC2 instance for the Laravel application
resource "aws_instance" "laravel_app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
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
    Name = "laravel-app-instance"
  }
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

# Create a DB subnet group using private subnets for RDS
resource "aws_db_subnet_group" "default" {
  name       = "main-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "main-db-subnet-group"
  }
}

# Create a MySQL RDS instance in private subnets
resource "aws_db_instance" "default" {
  identifier              = "laravel-db"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.ec2_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false

  tags = {
    Name = "laravel-db"
  }
}
