#!/usr/bin/env python3
"""
Foundry
=======
Reads project.config.yml and casts a clean, complete project structure
with only the files relevant to your chosen cloud provider and language.

Usage:
    python generate.py
    python generate.py --config my-other-project.config.yml
"""

import os
import sys
import shutil
import argparse
from pathlib import Path

try:
    import yaml
except ImportError:
    print("❌  PyYAML is required. Run: pip install pyyaml")
    sys.exit(1)


TEMPLATES_DIR = Path(__file__).parent / "templates"

VALID_CLOUDS     = ["azure", "aws", "gcp"]
VALID_LANGUAGES  = ["node", "python", "dotnet", "go", "java"]


# ──────────────────────────────────────────────────────────────
# Config loading & validation
# ──────────────────────────────────────────────────────────────

def load_config(config_path: str) -> dict:
    try:
        with open(config_path) as f:
            config = yaml.safe_load(f)
    except FileNotFoundError:
        print(f"❌  Config file not found: {config_path}")
        sys.exit(1)

    errors = []

    def require(path: str, value):
        if not value:
            errors.append(path)

    require("project.name",     config.get("project", {}).get("name"))
    require("project.team",     config.get("project", {}).get("team"))
    require("cloud.provider",   config.get("cloud", {}).get("provider"))
    require("cloud.region",     config.get("cloud", {}).get("region"))
    require("language",         config.get("language"))
    require("port",             config.get("port"))
    require("output_dir",       config.get("output_dir"))

    if errors:
        print(f"❌  Missing required config fields: {', '.join(errors)}")
        sys.exit(1)

    if config["cloud"]["provider"] not in VALID_CLOUDS:
        print(f"❌  cloud.provider must be one of: {', '.join(VALID_CLOUDS)}")
        sys.exit(1)

    if config["language"] not in VALID_LANGUAGES:
        print(f"❌  language must be one of: {', '.join(VALID_LANGUAGES)}")
        sys.exit(1)

    return config


# ──────────────────────────────────────────────────────────────
# Replacement dictionary
# ──────────────────────────────────────────────────────────────

def build_replacements(config: dict) -> dict:
    app_name   = config["project"]["name"]
    cloud      = config["cloud"]["provider"]
    region     = config["cloud"]["region"]
    resources  = config.get("resources", {})
    app_clean  = app_name.replace("-", "").replace("_", "")
    github_org = config.get("github", {}).get("org", "YOUR_GITHUB_ORG")

    # Cloud-specific registry values, pre-computed so the
    # Taskfile and Terraform outputs are already wired up.
    if cloud == "azure":
        registry_url       = f"{app_clean}acr.azurecr.io"
        registry_login_cmd = f"az acr login --name {app_clean}acr"
    elif cloud == "aws":
        registry_url       = f"${{AWS_ACCOUNT_ID}}.dkr.ecr.{region}.amazonaws.com/{app_name}"
        registry_login_cmd = (
            f"aws ecr get-login-password --region {region} | "
            f"docker login --username AWS --password-stdin "
            f"${{AWS_ACCOUNT_ID}}.dkr.ecr.{region}.amazonaws.com"
        )
    else:  # gcp
        registry_url       = f"{region}-docker.pkg.dev/${{GCP_PROJECT_ID}}/{app_name}/{app_name}"
        registry_login_cmd = f"gcloud auth configure-docker {region}-docker.pkg.dev"

    # Language-specific commands pre-filled in the Taskfile
    language = config["language"]
    test_cmds = {
        "node":   ("npm test",             "npm run test:unit",   "npm run test:integration", "npm run lint"),
        "python": ("pytest",               "pytest tests/unit",   "pytest tests/integration", "ruff check ."),
        "dotnet": ("dotnet test",          "dotnet test --filter Category=Unit", "dotnet test --filter Category=Integration", "dotnet format --verify-no-changes"),
        "go":     ("go test ./...",        "go test ./... -run Unit", "go test ./... -run Integration", "golangci-lint run"),
        "java":   ("./mvnw test",          "./mvnw test -Dgroups=unit", "./mvnw test -Dgroups=integration", "./mvnw checkstyle:check"),
    }
    test_all, test_unit, test_integration, lint = test_cmds.get(language, ("echo 'add test command'", "echo 'add unit test command'", "echo 'add integration test command'", "echo 'add lint command'"))

    return {
        "<<APP_NAME>>":              app_name,
        "<<APP_NAME_CLEAN>>":        app_clean,
        "<<APP_NAME_UPPER>>":        app_name.upper().replace("-", "_"),
        "<<CLOUD_PROVIDER>>":        cloud,
        "<<REGION>>":                region,
        "<<TEAM>>":                  config["project"]["team"],
        "<<LANGUAGE>>":              language,
        "<<PORT>>":                  str(config["port"]),
        "<<CPU>>":                   str(resources.get("cpu", "0.5")),
        "<<MEMORY>>":                str(resources.get("memory", "1Gi")),
        "<<REGISTRY_URL>>":          registry_url,
        "<<REGISTRY_LOGIN_CMD>>":    registry_login_cmd,
        "<<GITHUB_ORG>>":            github_org,
        "<<TEST_CMD>>":              test_all,
        "<<TEST_UNIT_CMD>>":         test_unit,
        "<<TEST_INTEGRATION_CMD>>":  test_integration,
        "<<LINT_CMD>>":              lint,
    }


# ──────────────────────────────────────────────────────────────
# File operations
# ──────────────────────────────────────────────────────────────

def apply_replacements(content: str, replacements: dict) -> str:
    for placeholder, value in replacements.items():
        content = content.replace(placeholder, value)
    return content


def copy_file(src: Path, dst: Path, replacements: dict):
    dst.parent.mkdir(parents=True, exist_ok=True)
    try:
        content = src.read_text(encoding="utf-8")
        content = apply_replacements(content, replacements)
        dst.write_text(content, encoding="utf-8")
    except UnicodeDecodeError:
        shutil.copy2(src, dst)


def copy_dir(src: Path, dst: Path, replacements: dict):
    if not src.exists():
        print(f"  ⚠️   Template not found (skipping): {src.relative_to(TEMPLATES_DIR)}")
        return
    for file_path in sorted(src.rglob("*")):
        if file_path.is_file():
            relative  = file_path.relative_to(src)
            dest_file = dst / relative
            copy_file(file_path, dest_file, replacements)


# ──────────────────────────────────────────────────────────────
# Generator
# ──────────────────────────────────────────────────────────────

def generate(config: dict, replacements: dict):
    output_dir = Path(config["output_dir"]).expanduser().resolve()
    cloud      = config["cloud"]["provider"]
    language   = config["language"]
    app_name   = config["project"]["name"]
    envs       = config.get("environments", ["dev", "staging", "prod"])

    if output_dir.exists():
        print(f"❌  Output directory already exists: {output_dir}")
        print("    Delete it or choose a different output_dir in project.config.yml")
        sys.exit(1)

    print(f"\n  App:      {app_name}")
    print(f"  Cloud:    {cloud}  ({config['cloud']['region']})")
    print(f"  Language: {language}  (port {config['port']})")
    print(f"  Envs:     {', '.join(envs)}")
    print(f"  Output:   {output_dir}\n")

    # ── CI Adapters (cloud-specific auth, same pipeline logic)
    step("CI adapters", f".ci/  [{cloud}]")
    copy_dir(TEMPLATES_DIR / "ci" / cloud, output_dir / ".ci", replacements)

    # ── Docker (language-specific)
    step("Docker", f"Dockerfile  docker-compose.yml  .dockerignore")
    copy_dir(TEMPLATES_DIR / "docker" / language, output_dir, replacements)

    # ── Taskfile
    step("Taskfile", "Taskfile.yml")
    copy_file(
        TEMPLATES_DIR / "taskfile" / "Taskfile.yml",
        output_dir / "Taskfile.yml",
        replacements,
    )

    # ── Terraform modules (cloud-specific)
    step("Terraform modules", f"infrastructure/modules/  [{cloud}]")
    for module in ["container-runtime", "registry", "networking"]:
        copy_dir(
            TEMPLATES_DIR / "infrastructure" / "modules" / module / cloud,
            output_dir / "infrastructure" / "modules" / module,
            replacements,
        )

    # ── Terraform environments
    step("Terraform environments", f"infrastructure/environments/  {envs}")
    env_base = TEMPLATES_DIR / "infrastructure" / "environments" / cloud
    for env in envs:
        env_dst = output_dir / "infrastructure" / "environments" / env
        # Shared main.tf + variables.tf (same across envs, differ only by tfvars)
        for shared in ["main.tf", "variables.tf"]:
            src = env_base / shared
            if src.exists():
                copy_file(src, env_dst / shared, replacements)
        # Environment-specific overrides (tfvars, backend config)
        copy_dir(env_base / env, env_dst, replacements)

    # ── State bootstrap (cloud-specific, run once)
    step("State bootstrap", f"infrastructure/state-bootstrap/  [{cloud}]")
    copy_dir(
        TEMPLATES_DIR / "infrastructure" / "state-bootstrap" / cloud,
        output_dir / "infrastructure" / "state-bootstrap",
        replacements,
    )

    # ── OIDC trust module (cloud-specific, run once)
    step("OIDC trust", f"infrastructure/oidc/  [{cloud}]")
    copy_dir(
        TEMPLATES_DIR / "infrastructure" / "oidc" / cloud,
        output_dir / "infrastructure" / "oidc",
        replacements,
    )

    # ── Misc root files
    copy_file(TEMPLATES_DIR / "env.example",  output_dir / ".env.example", replacements)
    copy_file(TEMPLATES_DIR / "gitignore",    output_dir / ".gitignore",   replacements)

    # Done
    print(f"\n{'═' * 52}")
    print(f"  ✅  Project generated: {output_dir}")
    print(f"{'═' * 52}")
    print("""
  Next steps
  ──────────
  1.  cd into your project directory
  2.  git init && git add . && git commit -m "Cast from Foundry"
  3.  task oidc:setup               # configure CI → cloud trust (once)
  4.  task infra:bootstrap          # provision remote state (once)
  5.  task dev                      # start local dev stack
  6.  task deploy ENV=dev           # first deploy
""")


def step(label: str, detail: str):
    print(f"  ▸  {label:<26} {detail}")


# ──────────────────────────────────────────────────────────────
# Entry point
# ──────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Cast a new project from Foundry")
    parser.add_argument(
        "--config", default="project.config.yml",
        help="Path to the project config file (default: project.config.yml)"
    )
    args = parser.parse_args()

    print(f"\n{'═' * 52}")
    print("    🛠️   Foundry")
    print(f"{'═' * 52}")

    config       = load_config(args.config)
    replacements = build_replacements(config)
    generate(config, replacements)


if __name__ == "__main__":
    main()
