# Foundry

A project generator that casts fully wired, production-ready projects from a single config file. Every project comes out of Foundry the same way — containerised, infrastructure-ready, and wired to any CI platform — all standardised, none of it repeated.

---

## What it generates

Fill in `project.config.yml`, run `python generate.py`, and get a clean project with:

| Layer | Tool | Detail |
|---|---|---|
| **Containerisation** | Docker | Multi-stage build, non-root user, health check |
| **Local dev** | Docker Compose | Hot reload, matches production image |
| **IaC** | Terraform | Modules for networking, registry, container runtime |
| **State** | Cloud-native backend | Azure Blob / S3+DynamoDB / GCS — provisioned by bootstrap |
| **Pipeline logic** | Taskfile | Single source of truth — runs identically locally or in CI |
| **CI/CD** | Thin adapters | GitHub Actions, GitLab CI, Bitbucket, Jenkins |

The generated project contains **only** the files relevant to your chosen cloud and language. If you pick AWS, there is no Azure code in the output.

---

## Prerequisites

- Python 3.8+
- `pip install -r requirements.txt`

That's it for generation. The generated project additionally requires:
- [Task](https://taskfile.dev/installation/) — `brew install go-task`
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.6
- [Docker](https://docs.docker.com/get-docker/)
- Cloud CLI (`az` / `aws` / `gcloud`) depending on your target cloud

---

## Usage

### 1. Clone this repo

```bash
git clone git@github.com:you/foundry.git
cd foundry
pip install -r requirements.txt
```

### 2. Configure your project

Edit `project.config.yml`:

```yaml
project:
  name: payments-api    # kebab-case — used for all resource names
  team: platform

cloud:
  provider: azure       # azure | aws | gcp
  region: uksouth

language: node          # node | python | dotnet | go | java
port: 3000

resources:
  cpu: "0.5"
  memory: "1Gi"

environments:
  - dev
  - staging
  - prod

output_dir: ../payments-api
```

### 3. Generate

```bash
python generate.py
```

Output:

```
════════════════════════════════════════════════════
    🛠️   Foundry
════════════════════════════════════════════════════

  App:      payments-api
  Cloud:    azure  (uksouth)
  Language: node  (port 3000)
  Envs:     dev, staging, prod
  Output:   /Users/you/repos/payments-api

  ▸  CI adapters               .ci/
  ▸  Docker (node)             Dockerfile  docker-compose.yml  .dockerignore
  ▸  Taskfile                  Taskfile.yml
  ▸  Terraform modules         infrastructure/modules/  [azure]
  ▸  Terraform environments    infrastructure/environments/  ['dev', 'staging', 'prod']
  ▸  State bootstrap           infrastructure/state-bootstrap/  [azure]

════════════════════════════════════════════════════
  ✅  Project generated: /Users/you/repos/payments-api
════════════════════════════════════════════════════

  Next steps
  ──────────
  1.  cd into your project directory
  2.  git init && git add . && git commit -m "Cast from Foundry"
  3.  task infra:bootstrap          # provision remote state (once)
  4.  task dev                      # start local dev stack
  5.  task deploy ENV=dev           # first deploy
```

### 4. Bootstrap remote state (once per project)

```bash
cd ../payments-api
task infra:bootstrap
```

This creates the Terraform state backend in your cloud account. Every subsequent `terraform` command stores its state there automatically.

### 5. Start developing

```bash
task dev             # start local stack with hot reload
task --list          # see all available commands
```

---

## Generated project structure

```
my-app/
├── Taskfile.yml                    ← all pipeline commands live here
├── .env.example                    ← copy to .env, fill in secrets
├── .gitignore
│
├── Dockerfile                      ← multi-stage build for your language
├── .dockerignore
├── docker-compose.yml              ← local dev with hot reload
│
├── infrastructure/
│   ├── modules/
│   │   ├── container-runtime/      ← Container Apps / ECS Fargate / Cloud Run
│   │   ├── registry/               ← ACR / ECR / Artifact Registry
│   │   └── networking/             ← VNet/VPC + environment
│   ├── environments/
│   │   ├── dev/
│   │   │   ├── main.tf             ← wires all modules for dev
│   │   │   ├── variables.tf
│   │   │   ├── terraform.tfvars    ← dev sizing (small, scale-to-zero)
│   │   │   └── backend.hcl         ← remote state path for dev
│   │   ├── staging/
│   │   └── prod/
│   └── state-bootstrap/            ← run once: provisions the state backend
│
└── .ci/
    ├── github-actions.yml          ← ~20 lines, calls `task ci` and `task deploy`
    ├── gitlab-ci.yml
    ├── bitbucket-pipelines.yml
    └── Jenkinsfile
```

---

## Key design decisions

### CI/CD: Taskfile + thin adapters

All pipeline logic — build, test, scan, push, deploy — lives in `Taskfile.yml`. The CI adapter files are intentionally thin (~15–20 lines) and **identical across all your projects**. They contain no app-specific values; those come from the Taskfile and cloud secrets.

This means:
- **Switching Git hosts** requires no pipeline rewrite — you already have adapters for all platforms
- **Running locally** works exactly as in CI: `task ci`, `task deploy ENV=dev`
- **Debugging a pipeline failure** is as simple as running the same `task` command on your machine

### Infrastructure abstraction

The three Terraform modules (`container-runtime`, `registry`, `networking`) share identical variable names across Azure, AWS, and GCP. The calling `environments/*/main.tf` is the same shape regardless of cloud — only the provider block changes.

| Module | Azure | AWS | GCP |
|---|---|---|---|
| `container-runtime` | Container Apps | ECS Fargate | Cloud Run |
| `registry` | ACR | ECR | Artifact Registry |
| `networking` | VNet + CAE | VPC + subnets | VPC + VPC connector |

### Remote state from day one

`task infra:bootstrap` provisions the state backend **before** any project infrastructure is created, using local state only for the bootstrap itself. From that point, all Terraform runs go to remote state with locking — no manual setup, no state committed to git.

| Cloud | Backend | Lock mechanism |
|---|---|---|
| Azure | Azure Blob Storage (LRS) | Blob lease |
| AWS | S3 (versioned + encrypted) | DynamoDB table |
| GCP | GCS (versioned) | Built-in GCS locking |

---

## Taskfile reference

```bash
task dev                  # start local stack
task build                # build container image
task test                 # run tests in container
task scan                 # vulnerability scan (Trivy)
task ci                   # build + test + scan (what CI calls)

task infra:bootstrap      # provision state backend (once)
task infra:init  ENV=dev  # terraform init
task infra:plan  ENV=dev  # terraform plan
task infra:apply ENV=dev  # terraform apply

task push        ENV=dev TAG=abc123   # push image to registry
task deploy      ENV=dev TAG=abc123   # ci + push + infra:apply
task deploy:dev                       # shorthand
task deploy:staging
task deploy:prod                      # prompts for confirmation
```

---

## Adding a new language

1. Create `templates/docker/<language>/Dockerfile`, `.dockerignore`, `docker-compose.yml`
2. Add the language name to `VALID_LANGUAGES` in `generate.py`
3. Update the `<<TEST_CMD>>` placeholder in `Taskfile.yml` to suit the language's test runner

---

## Adding a new cloud

1. Create the three module directories under `templates/infrastructure/modules/*/newcloud/`
2. Create environment files under `templates/infrastructure/environments/newcloud/`
3. Create state bootstrap under `templates/infrastructure/state-bootstrap/newcloud/`
4. Update `VALID_CLOUDS` and the `build_replacements` function in `generate.py` with registry URL and login command patterns
