# RDS Database Module

This Terraform module creates an AWS RDS MySQL database instance with the following components:

## Components

- **RDS Instance**: MySQL 8.0 database with encryption enabled
- **Security Group**: Allows MySQL access (port 3306) from the VPC
- **Subnet Group**: Database subnets for high availability
- **Parameter Group**: Custom MySQL parameters for performance
- **Random Password**: Auto-generated secure database password

## Configuration

The module uses Terraform Cloud backend with the following configuration:
- Organization: `Asm_aziz_stage`
- Workspace: `db-workspace`

## Variables

Key configurable variables in `variables.tf`:

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `us-east-1` |
| `project_name` | Project name prefix | `laraveldevops` |
| `environment` | Environment (dev/staging/prod) | `dev` |
| `db_instance_class` | RDS instance type | `db.t3.micro` |
| `db_allocated_storage` | Initial storage in GB | `20` |
| `db_name` | Database name | `laravel_db` |
| `db_username` | Database master username | `admin` |

## Outputs

The module outputs the following values for use by other infrastructure:

- `db_endpoint`: Database connection endpoint
- `db_port`: Database port (3306)
- `db_name`: Database name
- `db_username`: Database username (sensitive)
- `db_password`: Auto-generated password (sensitive)
- `db_connection_string`: Full connection string (sensitive)

## Pipeline

The RDS module has its own GitLab CI pipeline in `.gitlab-ci.yml` that:

1. **Validates** Terraform configuration on any RDS changes
2. **Plans** infrastructure changes 
3. **Applies** changes automatically on main branch
4. **Destroys** infrastructure manually on destroy branch

### Pipeline Triggers

The pipeline runs only when files in the `rds/` folder are modified:
```yaml
rules:
  - changes:
      - rds/**/*
    when: always
```

## Usage

### Deploy RDS

1. Modify any file in the `rds/` folder
2. Commit and push to trigger the pipeline
3. Pipeline will validate, plan, and apply changes

### Access Database Outputs

The infrastructure module (`infra/`) can access RDS outputs via remote state:

```hcl
data "terraform_remote_state" "rds" {
  backend = "remote"
  
  config = {
    organization = "Asm_aziz_stage"
    workspaces = {
      name = "db-workspace"
    }
  }
}

# Use outputs
locals {
  db_endpoint = data.terraform_remote_state.rds.outputs.db_endpoint
  db_password = data.terraform_remote_state.rds.outputs.db_password
}
```

### Environment Variables

The following environment variables are required in GitLab CI:

- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- `AWS_DEFAULT_REGION`: AWS region
- `TF_TOKEN_app_terraform_io`: Terraform Cloud API token

## Security

- Database password is auto-generated and stored in Terraform state
- All outputs containing credentials are marked as sensitive
- Security group restricts access to VPC CIDR only
- Storage encryption is enabled by default
- Deletion protection is enabled by default

## Customization

To customize the database configuration:

1. Modify variables in `variables.tf`
2. Update resource configurations in `main.tf`
3. Commit changes to trigger deployment

Example: Change to PostgreSQL:
```hcl
variable "db_engine" {
  default = "postgres"
}

variable "db_engine_version" {
  default = "14.9"
}
```