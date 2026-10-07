# LaravelDevOps

One Laravel application, deployed four different ways — to compare the trade-offs between
traditional VPS hosting and cloud-native infrastructure, with a single GitLab pipeline driving
both.

The application itself is deliberately ordinary. Everything interesting is in how it gets built,
tested, provisioned, and shipped.

---

## The four deployment paths

| Path | Target | Provisioning | Release |
|---|---|---|---|
| **Docker Compose** | Any Linux host | Manual | `docker compose up` |
| **VPS + Ansible** | Self-managed VPS | Manual host setup | Ansible playbook, staging inventory |
| **AWS + Terraform** | EC2 + RDS | Terraform (two modules) | Ansible playbook, production inventory |
| **Kubernetes** | Any cluster | Manifests | `kubectl apply -f k8s/` |

Both the VPS and AWS paths are wired into the same pipeline and run on every push to `main` —
staging to the VPS, production to AWS.

---

## Pipeline

Seven stages, defined in [`.gitlab-ci.yml`](.gitlab-ci.yml):

```
build ──→ test ──→ database ──→ staging_deploy ──→ prod_infra ──→ prod_deploy ──→ destroy
                                                                                  (manual)
```

| Stage | What happens |
|---|---|
| `build` | Builds and pushes the PHP-FPM and Nginx images, using `--cache-from` against the previous `latest` tag so unchanged layers are reused |
| `test` | Installs dependencies and runs `php artisan test` against SQLite; GitLab SAST runs alongside |
| `database` | Applies the `rds/` Terraform module — triggered only when files under `rds/` change |
| `staging_deploy` | Generates an Ansible inventory on the fly and deploys to the VPS over SSH |
| `prod_infra` | `terraform fmt -check`, `init`, `validate`, then `apply` — validation is a separate job that must pass before apply runs |
| `prod_deploy` | Deploys to the provisioned EC2 instance via Ansible |
| `destroy` | `terraform destroy`, manual trigger only, on a dedicated branch — so a stray push can never tear down infrastructure |

### How credentials reach the application

No database credentials are written to the repository or to CI variables. Terraform generates
them, exposes them as outputs, and the pipeline passes them forward as job artifacts:

```
terraform apply ──→ terraform output ──→ job artifacts ──→ ansible env template ──→ container .env
```

The production deploy job reads `db_endpoint.txt`, `db_username.txt`, `db_password.txt`, and
`ec2_ip.txt` from the previous stage and templates them into the runtime `.env`. The application
never knows where its database lives until Terraform has decided.

---

## Infrastructure

Terraform is split into two modules so that database lifecycle is independent of compute
lifecycle — you can rebuild the application tier without putting the database at risk.

```
rds/        VPC (10.0.0.0/16), private subnets (10.0.1.0/24, 10.0.2.0/24), multi-AZ MySQL RDS
infra/      EC2 in public subnet (10.0.3.0/24), security groups, consumes rds/ outputs via remote state
```

State lives in Terraform Cloud, not in the repository. RDS sits in private subnets with a security
group that only admits traffic from within the VPC — it has no public route.

See [`INFRASTRUCTURE.md`](INFRASTRUCTURE.md) for the full network layout, and
[`VPS_vs_CLOUD_COMPARISON.md`](VPS_vs_CLOUD_COMPARISON.md) for the cost and operational comparison
that motivated building both.

---

## Deployment with Ansible

Two roles, one per environment, sharing the same shape:

```
ansible/
  staging.yml              → roles/deploy       (VPS)
  production.yml           → roles/deploy_prod  (EC2)
  roles/*/tasks/
    main.yml               orchestration
    backup.yml             snapshot current release before touching it
    health_check.yml       verify the new release answers before declaring success
    rollback.yml           restore the most recent backup
  roles/*/templates/
    docker-compose.*.yml.j2
    env.j2
```

Every deploy takes a timestamped backup first. `rollback.yml` finds the most recent one and
restores it, and fails loudly rather than silently if no backup exists. Compose files and env
files are Jinja2 templates rendered per environment, so staging and production cannot drift apart
by hand-editing.

---

## Repository layout

```
.gitlab-ci.yml        Seven-stage pipeline
php.dockerfile        PHP 8.2-FPM image
nginx/                Nginx image and reverse-proxy config
docker-compose.yml    Local development stack
infra/                Terraform — EC2, security groups, outputs
rds/                  Terraform — VPC, subnets, RDS
ansible/              Staging and production roles, inventories, templates
k8s/                  Namespace, deployments, services, ConfigMap template
app/ routes/ tests/   The Laravel application
```

---

## Running it locally

```bash
cp .env.template .env
docker compose up -d
docker compose exec app php artisan key:generate
docker compose exec app php artisan migrate
```

The application is then served by Nginx on the port mapped in `docker-compose.yml`.

### Required CI/CD variables

| Variable | Purpose |
|---|---|
| `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION` | Terraform AWS provider |
| `TF_TOKEN_app_terraform_io` | Terraform Cloud remote state |
| `DOCKER_USERNAME`, `DOCKER_PASSWORD`, `DOCKER_REGISTRY` | Image registry |
| `SSH_VPS`, `SSH_PRIVATE_KEY` | Deploy keys for VPS and EC2 |
| `APP_KEY` | Laravel application key |

---

## Notes on secrets

`k8s/secrets.yaml` is gitignored; [`k8s/secrets.yaml.example`](k8s/secrets.yaml.example) shows the
expected shape with empty values. Terraform state is gitignored and kept in Terraform Cloud.
Staging database passwords are generated at deploy time with `openssl rand` when not supplied.

---

## Why build the same thing four times

The point was to feel the trade-offs rather than read about them. A VPS is cheaper and simpler
until you need a second machine. Terraform costs more up front and pays for itself the first time
an environment has to be rebuilt from nothing. Ansible is the right tool for "configure this host"
and the wrong one for "create this host." Kubernetes solves problems this application does not
have yet.

`VPS_vs_CLOUD_COMPARISON.md` has the numbers behind each of those claims.
