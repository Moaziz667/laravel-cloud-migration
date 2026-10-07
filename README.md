# Laravel Cloud Migration

> **CI/CD runs on GitLab.** GitHub does not execute `.gitlab-ci.yml`, so no workflows run here.
> The pipeline definition is [`.gitlab-ci.yml`](.gitlab-ci.yml), and the runs themselves are at
> [gitlab.com/mohamedaziz.hadjkacem21/laraveldevops](https://gitlab.com/mohamedaziz.hadjkacem21/laraveldevops/-/pipelines).

Taking one Laravel application from a hand-managed VPS to infrastructure provisioned entirely in
Terraform on AWS, and keeping both targets alive side by side so the trade-offs can be measured
rather than guessed.

The application itself is deliberately ordinary. Everything interesting is in how it gets built,
tested, provisioned, and shipped.

---

## Deployment targets

Two are automated and run on every push to `main`:

| Target | Provisioning | Release |
|---|---|---|
| **Staging — self-managed VPS** | Manual host setup | Ansible playbook, staging inventory |
| **Production — AWS EC2 + RDS** | Terraform, three roots | Ansible playbook, production inventory |

Two more exist for local work and experimentation, and are **not** part of the pipeline:

| Target | Status |
|---|---|
| **Docker Compose** | Local development stack |
| **Kubernetes** (`k8s/`) | Manifests written and applied by hand; never wired into CI |

Being explicit about that split is the point — the Kubernetes manifests are a sketch of where this
would go next, not a third production path.

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
rds/        VPC (10.0.0.0/16), private subnets (10.0.1.0/24, 10.0.2.0/24), MySQL RDS
infra/      EC2 in public subnet (10.0.3.0/24), security groups, consumes rds/ outputs via remote state
```

State lives in Terraform Cloud, not in the repository. RDS sits in private subnets with a security
group that only admits traffic from within the VPC, has `storage_encrypted = true`, a configurable
backup retention period, and a timestamped final snapshot on destroy unless explicitly skipped.

Subnets are spread across two availability zones and registered in a DB subnet group, so Multi-AZ
can be switched on without re-architecting the network. It is currently off (`multi_az = false`) —
this is a study project and the standby instance doubles the bill.

See [`INFRASTRUCTURE.md`](INFRASTRUCTURE.md) for the full network layout, and
[`VPS_vs_CLOUD_COMPARISON.md`](VPS_vs_CLOUD_COMPARISON.md) for the cost and operational comparison
that motivated building both.

---

## Deployment with Ansible

Two roles, one per environment:

```
ansible/
  staging.yml              → roles/deploy       (VPS)
  production.yml           → roles/deploy_prod  (EC2)
  roles/deploy/tasks/
    main.yml               orchestration
    backup.yml             snapshot current release before touching it
    health_check.yml       verify the new release answers before declaring success
    rollback.yml           restore the most recent backup
  roles/deploy_prod/tasks/
    main.yml               orchestration, with backup and rollback inlined
  roles/*/templates/
    docker-compose.*.yml.j2
    env.j2
```

Every deploy takes a timestamped backup first. Rollback finds the most recent one and restores it,
and fails loudly rather than silently if no backup exists.

In production the risky step is the migration, so it runs inside a `block`/`rescue`: if
`artisan migrate` fails, the rescue restores the backup and then fails the deploy deliberately,
rather than leaving a half-migrated database behind a running container. Staging additionally has a
separate health-check task; production does not, which is the main gap between the two.

Compose files and env files are Jinja2 templates rendered per environment, so staging and
production cannot drift apart by hand-editing.

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

## Why keep both

The point was to feel the trade-offs rather than read about them. A VPS is cheaper and simpler
until you need a second machine. Terraform costs more up front and pays for itself the first time
an environment has to be rebuilt from nothing. Ansible is the right tool for "configure this host"
and the wrong one for "create this host." Kubernetes solves problems this application does not
have yet, which is why its manifests stayed out of the pipeline.

Running both targets from one pipeline meant every claim could be checked against a real deploy
instead of a blog post.

`VPS_vs_CLOUD_COMPARISON.md` has the numbers behind each of those claims.
