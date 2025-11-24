data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "staging" {
  cidr_block           = "10.30.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = "staging"
  }
}

resource "aws_internet_gateway" "staging" {
  vpc_id = aws_vpc.staging.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = "staging"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.staging.id
  cidr_block              = "10.30.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = "${var.project_name}-public"
    Environment = "staging"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.staging.id
  cidr_block        = "10.30.10.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = "${var.project_name}-private-a"
    Environment = "staging"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.staging.id
  cidr_block        = "10.30.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name        = "${var.project_name}-private-b"
    Environment = "staging"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.staging.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.staging.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = "staging"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Allow SSH and web traffic"
  vpc_id      = aws_vpc.staging.id

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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-app-sg"
    Environment = "staging"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Allow MySQL traffic from app security group"
  vpc_id      = aws_vpc.staging.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-db-sg"
    Environment = "staging"
  }
}

resource "aws_security_group_rule" "db_from_app" {
  description              = "Allow MySQL from app security group"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  security_group_id        = aws_security_group.db.id
}

resource "aws_db_subnet_group" "staging" {
  name       = "${var.project_name}-db-subnets"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name        = "${var.project_name}-db-subnets"
    Environment = "staging"
  }
}

resource "random_password" "db" {
  length  = 16
  special = true
}

resource "aws_db_instance" "staging" {
  identifier              = "${var.project_name}-db"
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = 20
  db_name                 = var.db_name
  username                = var.db_username
  password                = random_password.db.result
  publicly_accessible     = false
  multi_az                = false
  skip_final_snapshot     = true
  deletion_protection     = false
  vpc_security_group_ids  = [aws_security_group.db.id]
  db_subnet_group_name    = aws_db_subnet_group.staging.name
  backup_retention_period = 1
  apply_immediately       = true
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  key_name                    = var.ssh_key_name
  associate_public_ip_address = true

  tags = {
    Name        = "${var.project_name}-app"
    Environment = "staging"
  }
}
