terraform { 

  cloud { terraform { 

    organization = "Asm_aziz_stage"   cloud { 

    workspaces {     

      name = "deploy-infra"     organization = "Asm_aziz_stage" 

    } 

  }     workspaces { 

}      name = "deploy-infra" 

    } 

# Data source to read RDS outputs from remote state  } 

data "terraform_remote_state" "rds" {}

  backend = "remote"

  # Data source to read RDS outputs from remote state

  config = {data "terraform_remote_state" "rds" {

    organization = "Asm_aziz_stage"  backend = "remote"

    workspaces = {  

      name = "db-workspace"  config = {

    }    organization = "Asm_aziz_stage"

  }    workspaces = {

}      name = "db-workspace"

    }

# Get available AZs  }

data "aws_availability_zones" "available" {}

  state = "available"

}# Local values for database configuration

locals {

# Use the latest Ubuntu AMI for the EC2 instance  db_endpoint = try(data.terraform_remote_state.rds.outputs.db_endpoint, "localhost")

data "aws_ami" "ubuntu" {  db_port     = try(data.terraform_remote_state.rds.outputs.db_port, "3306")

  most_recent = true  db_name     = try(data.terraform_remote_state.rds.outputs.db_name, "laravel_db")

  db_username = try(data.terraform_remote_state.rds.outputs.db_username, "admin")

  filter {  db_password = try(data.terraform_remote_state.rds.outputs.db_password, "defaultpass")

    name   = "name"  db_security_group_id = try(data.terraform_remote_state.rds.outputs.db_security_group_id, "")

    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]  

  }  # Use RDS VPC instead of creating our own

  vpc_id = try(data.terraform_remote_state.rds.outputs.rds_vpc_id, "")

  filter {  vpc_cidr_block = try(data.terraform_remote_state.rds.outputs.rds_vpc_cidr_block, "10.1.0.0/16")

    name   = "virtualization-type"}

    values = ["hvm"]

  }# Use the existing RDS VPC (don't create a new one)

# Create subnets in the existing RDS VPC for EC2

  owners = ["099720109477"] # Canonical Ubuntu owner IDresource "aws_subnet" "public_subnet" {

}  vpc_id                  = local.vpc_id

  cidr_block              = var.public_subnet_cidr

# Local values for database configuration  map_public_ip_on_launch = true

locals {  availability_zone       = data.aws_availability_zones.available.names[0]

  db_endpoint = try(data.terraform_remote_state.rds.outputs.db_endpoint, "localhost")

  db_port     = try(data.terraform_remote_state.rds.outputs.db_port, "3306")  tags = {

  db_name     = try(data.terraform_remote_state.rds.outputs.db_name, "laravel_db")    Name = "public-subnet-ec2"

  db_username = try(data.terraform_remote_state.rds.outputs.db_username, "admin")  }

  db_password = try(data.terraform_remote_state.rds.outputs.db_password, "defaultpass")}

  db_security_group_id = try(data.terraform_remote_state.rds.outputs.db_security_group_id, "")

  resource "aws_subnet" "private_subnet" {

  # Use RDS VPC instead of creating our own  vpc_id            = local.vpc_id

  vpc_id = try(data.terraform_remote_state.rds.outputs.rds_vpc_id, "")  cidr_block        = var.private_subnet_cidr

  vpc_cidr_block = try(data.terraform_remote_state.rds.outputs.rds_vpc_cidr_block, "10.0.0.0/16")  availability_zone = data.aws_availability_zones.available.names[1]

  igw_id = try(data.terraform_remote_state.rds.outputs.rds_igw_id, "")

}  tags = {

    Name = "private-subnet-ec2"

# Create public subnet for EC2 in the existing RDS VPC  }

resource "aws_subnet" "public_subnet" {}

  vpc_id                  = local.vpc_id

  cidr_block              = var.public_subnet_cidr# Get available AZs

  map_public_ip_on_launch = truedata "aws_availability_zones" "available" {

  availability_zone       = data.aws_availability_zones.available.names[0]  state = "available"

}

  tags = {

    Name = "public-subnet-ec2"# Use the existing Internet Gateway from RDS VPC

    Project = var.project_name# No need to create a new IGW, use the one from RDS

  }

}# Create a public subnet with automatic public IP assignment

resource "aws_subnet" "public_subnet" {

# Create private subnet for EC2 in the existing RDS VPC  vpc_id                  = local.vpc_id

resource "aws_subnet" "private_subnet" {  cidr_block              = var.public_subnet_cidr

  vpc_id            = local.vpc_id  map_public_ip_on_launch = true

  cidr_block        = var.private_subnet_cidr  availability_zone       = data.aws_availability_zones.available.names[0]

  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {

  tags = {    Name = "public-subnet"

    Name = "private-subnet-ec2"  }

    Project = var.project_name}

  }

}# Create a private subnet in the VPC

resource "aws_subnet" "private_subnet" {

# Create a route table for the public subnet  vpc_id            = local.vpc_id

resource "aws_route_table" "public_rt" {  cidr_block        = var.private_subnet_cidr

  vpc_id = local.vpc_id  availability_zone = data.aws_availability_zones.available.names[1]



  route {  tags = {

    cidr_block = "0.0.0.0/0"    Name = "private-subnet"

    gateway_id = local.igw_id  }

  }}



  tags = {# Create a route table for the public subnet

    Name = "public-route-table"resource "aws_route_table" "public_rt" {

    Project = var.project_name  vpc_id = local.vpc_id

  }

}  route {

    cidr_block = "0.0.0.0/0"

# Associate the public subnet with the public route table    gateway_id = try(data.terraform_remote_state.rds.outputs.rds_igw_id, "")

resource "aws_route_table_association" "public_association" {  }

  subnet_id      = aws_subnet.public_subnet.id

  route_table_id = aws_route_table.public_rt.id  tags = {

}    Name = "public-route-table"

  }

# Security group for EC2 to allow SSH, HTTP, HTTPS, and MySQL access}

resource "aws_security_group" "ec2_sg" {

  name        = "${var.project_name}-ec2-sg"

  description = "Allow SSH and HTTP(s) traffic for EC2"# Associate the public subnet with the public route table

  vpc_id      = local.vpc_idresource "aws_route_table_association" "public_association" {

  subnet_id      = aws_subnet.public_subnet.id

  ingress {  route_table_id = aws_route_table.public_rt.id

    description = "SSH"}

    from_port   = 22

    to_port     = 22# Security group to allow SSH, HTTP, HTTPS, and MySQL access

    protocol    = "tcp"resource "aws_security_group" "ec2_sg" {

    cidr_blocks = ["0.0.0.0/0"]  name        = "ec2-security-group"

  }  description = "Allow SSH and HTTP(s) traffic"

  vpc_id      = local.vpc_id

  ingress {

    description = "HTTP"  ingress {

    from_port   = 80    description = "SSH"

    to_port     = 80    from_port   = 22

    protocol    = "tcp"    to_port     = 22

    cidr_blocks = ["0.0.0.0/0"]    protocol    = "tcp"

  }    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    description = "HTTPS"  ingress {

    from_port   = 443    description = "HTTP"

    to_port     = 443    from_port   = 80

    protocol    = "tcp"    to_port     = 80

    cidr_blocks = ["0.0.0.0/0"]    protocol    = "tcp"

  }    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {

    description = "Allow all outbound traffic"  ingress {

    from_port   = 0    description = "HTTPS"

    to_port     = 0    from_port   = 443

    protocol    = "-1"    to_port     = 443

    cidr_blocks = ["0.0.0.0/0"]    protocol    = "tcp"

  }    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {

    Name = "${var.project_name}-ec2-sg"  ingress {

    Project = var.project_name    from_port   = 3306

  }    to_port     = 3306

}    protocol    = "tcp"

    description = "Allow MySQL access within security group"

# Security group rule to allow EC2 to connect to RDS  }

resource "aws_security_group_rule" "ec2_to_rds" {

  type                     = "egress"  egress {

  from_port                = 3306    description = "Allow all outbound traffic"

  to_port                  = 3306    from_port   = 0

  protocol                 = "tcp"    to_port     = 0

  source_security_group_id = local.db_security_group_id    protocol    = "-1"

  security_group_id        = aws_security_group.ec2_sg.id    cidr_blocks = ["0.0.0.0/0"]

  description              = "Allow EC2 to connect to RDS"  }

}

  # Specific rule for MySQL/RDS connection

# Create an EC2 instance for the Laravel application  egress {

resource "aws_instance" "laravel_app" {    description = "MySQL to RDS"

  ami                         = data.aws_ami.ubuntu.id    from_port   = 3306

  instance_type               = var.instance_type    to_port     = 3306

  subnet_id                   = aws_subnet.public_subnet.id    protocol    = "tcp"

  key_name                    = var.key_name    cidr_blocks = [local.vpc_cidr_block]

  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]  }

  associate_public_ip_address = true

  tags = {

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {    Name = "ec2-sg"

    db_host     = local.db_endpoint  }

    db_port     = local.db_port}

    db_name     = local.db_name

    db_username = local.db_username# Create an EC2 instance for the Laravel application

    db_password = local.db_passwordresource "aws_instance" "laravel_app" {

  }))  ami                         = data.aws_ami.ubuntu.id

  instance_type               = "t3.micro"

  tags = {  subnet_id                   = aws_subnet.public_subnet.id

    Name = "${var.project_name}-app-instance"  key_name                    = var.key_name

    Project = var.project_name  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]

  }  associate_public_ip_address = true

}
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
