# TODO

- [x] ~~Snapshot current Terraform state files (`infra/`, `rds/`) for reference before restructuring.~~
- [x] ~~Remove existing Terraform configs under `rds/` and rebuild a clean module that provisions the RDS VPC, subnets, security groups, and DB instance.~~
- [x] ~~Expose remote state outputs from the rebuilt `rds/` module (VPC ID, subnets, security group, DB endpoint, credentials).~~
- [x] ~~Recreate `infra/` Terraform configs to consume the RDS remote state and provision EC2 networking/resources in the shared VPC.~~
- [x] ~~Ensure EC2 security group ingress/egress rules allow connectivity to the RDS instance while maintaining least privilege.~~
- [x] ~~Update `rds/.gitlab-ci.yml` and root `.gitlab-ci.yml` so the RDS pipeline runs to completion before triggering the infra pipeline.~~
- [x] ~~Add proper dependency management using `needs` and `strategy: depend` in GitLab CI.~~
- [x] ~~Fixed CIDR block conflicts between RDS and EC2 subnets.~~
- [x] ~~Created clean separation between RDS and infrastructure modules.~~
- [x] ~~Added comprehensive documentation in `INFRASTRUCTURE.md`.~~
- [ ] Run Terraform `validate`/`plan` locally for both modules and capture outputs for later review.
- [ ] Test the pipeline in GitLab CI to ensure RDS deploys before infrastructure.
- [ ] Verify EC2 can connect to RDS database after deployment.
- [ ] Document any remaining environment variables or manual steps needed.
