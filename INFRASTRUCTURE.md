# Laravel DevOps Infrastructure

This project contains a clean, modular Terraform setup for deploying a Laravel application with RDS database and EC2 compute resources.

## Architecture

- **RDS Module** (`rds/`): Creates VPC, subnets, security groups, and MySQL RDS instance
- **Infrastructure Module** (`infra/`): Creates EC2 instance in the RDS VPC with proper connectivity
- **GitLab CI/CD**: Automated deployment pipeline with proper dependency management

## Deployment Flow

1. **RDS First**: The `rds/` module deploys the database infrastructure
2. **Infrastructure Second**: The `infra/` module deploys EC2 resources, consuming RDS outputs via Terraform remote state
3. **Application Deploy**: Laravel application is deployed to EC2 with database connectivity

## Network Architecture

- **VPC**: `10.0.0.0/16` (created by RDS module)
- **RDS Subnets**: `10.0.1.0/24`, `10.0.2.0/24` (private, multi-AZ)
- **EC2 Subnets**: `10.0.3.0/24` (public), `10.0.4.0/24` (private)

## Security

- RDS is deployed in private subnets with security group restricting access to VPC CIDR
- EC2 has specific security group rules for SSH, HTTP, HTTPS
- Database credentials are generated randomly and passed via Terraform remote state

## Required Environment Variables

```bash
# AWS Credentials
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_DEFAULT_REGION=eu-north-1

# Terraform Cloud Token
TF_TOKEN_app_terraform_io=your_terraform_token

# Application Secrets
APP_KEY=your_laravel_app_key
SSH_PRIVATE_KEY=your_ssh_private_key

# Docker Hub Credentials
DOCKER_USERNAME=your_docker_username
DOCKER_PASSWORD=your_docker_password
```

## Manual Operations

### Deploy RDS Only
```bash
cd rds/
terraform init
terraform apply
```

### Deploy Infrastructure Only
```bash
cd infra/
terraform init
terraform apply
```

### Destroy Resources
```bash
# Destroy in reverse order
cd infra/ && terraform destroy
cd ../rds/ && terraform destroy
```

## Terraform Workspaces

- **RDS**: `Asm_aziz_stage/db-workspace`
- **Infrastructure**: `Asm_aziz_stage/deploy-infra`

## Key Features

- ✅ Clean separation between database and compute infrastructure
- ✅ Proper dependency management via remote state
- ✅ Non-overlapping subnet CIDRs
- ✅ Security groups with least privilege access
- ✅ Automated CI/CD pipeline with proper sequencing
- ✅ Random password generation for database security
- ✅ Multi-AZ RDS deployment for high availability