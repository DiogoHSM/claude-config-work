# Guardrails — [Project Name]

> **Always loaded.** This file is the project's only *lazy-loading* contract: it tells Claude which docs to read before touching each area. Docs not listed here are read only when Claude opens them explicitly.

**Last revised**: [YYYY-MM-DD]

---

## Before editing

Use this table as a checklist. Before modifying a file that fits a category, **read the matching doc(s)** — even if it seems obvious.

**If the doc doesn't exist yet**: read `${CLAUDE_PLUGIN_ROOT}/templates/docs/<NAME>.md`, create `.claude/docs/<NAME>.md` filled with real project knowledge (explore the code if needed — don't leave fields as "TBD"), and **only then** proceed with the edit. This way documentation grows with decisions, no placeholder files.

| When touching… | Read first | Why |
|---|---|---|
| Deploy/CI files (`.github/workflows/**`, `samconfig.toml`, `serverless.yml`, `cdk.json`, `*.tf`, `vercel.json`, `cloudbuild.yaml`, `app.yaml`, `firebase.json`, `Dockerfile*`, `fly.toml`, `wrangler.toml`, `dagster.yaml`, `dagster_cloud.yaml`, `workspace.yaml`) | `DEPLOYMENT.md`, `INFRASTRUCTURE.md` | Avoid deploying to the wrong environment; respect the pipeline |
| Cloud infra (provisioning, regions, IAM, new resources) | `INFRASTRUCTURE.md`, `DECISIONS.md` | Validate org/account/region; check ADRs |
| dbt project (`dbt_project.yml`, `profiles.yml`, `models/**`, `macros/**`, `seeds/**`, `snapshots/**`) | `ARCHITECTURE.md`, `STACK.md`, `INFRASTRUCTURE.md` | Validate target (dev vs prod), warehouse account, schema scope |
| Snowflake DDL/DML, warehouse changes | `INFRASTRUCTURE.md`, `CONSTRAINTS.md`, `DECISIONS.md` | Validate account/role/warehouse before running |
| S3 buckets, lifecycle policies, replication | `INFRASTRUCTURE.md`, `CONSTRAINTS.md` | Bucket ownership / data residency |
| Migrations, schema, indexes, seeds (`**/migrations/**`, `*.sql`, `prisma/schema.prisma`, `schema.rb`) | `DECISIONS.md`, `CONSTRAINTS.md`, `ARCHITECTURE.md` | Data changes are irreversible — check constraints |
| New dependencies (`package.json`, `requirements.txt`, `pyproject.toml`, `go.mod`, `Gemfile`, `pom.xml`, `build.gradle*`) | `STACK.md`, `DECISIONS.md` | Align with prior stack decisions |
| Env vars, secrets, `.env*` files | `SECRETS.md`, `DEPLOYMENT.md` | Make sure the variable exists in every environment |
| Auth, permissions, RBAC, cookies, JWT | `CONSTRAINTS.md`, `ARCHITECTURE.md` | Security and compliance |
| Design system, UI components, tokens (`*.tsx`, `*.jsx`, `styles/**`, `tailwind.config.*`) | `UI-UX.md` | Visual coherence |
| Relevant architectural decision (new pattern, broad refactor) | `DECISIONS.md` (read + add ADR) | Traceability |
| Project scope/goals | `PROJECT-SUMMARY.md` | Vision alignment |

---

## Before destructive or irreversible actions

Mentally walk through this checklist. If any item fails, **stop and confirm with the user**.

- [ ] `check-context.sh` shows no 🔴 for any provider
- [ ] If the action involves cloud (deploy, delete, drop), the active account/project matches `INFRASTRUCTURE.md`
- [ ] If the action involves the database, there's a recent backup and the migration was tested locally
- [ ] If the action involves a protected branch or shared remote, the user authorized this specific operation

Destructive/irreversible actions: `rm -rf`, `DROP TABLE/SCHEMA`, `TRUNCATE`, `aws s3 rm`, `aws * delete`, `terraform destroy`, `kubectl delete`, `snow sql` with DDL drops, `dbt run --full-refresh` on prod, `dagster-cloud * delete`, `gcloud * delete`, `az * delete`, `vercel * rm`, `firebase * delete`, `git push --force`, `git reset --hard`, deleting branches, amending published commits, production deploys.

---

## Continuous update

- **Whenever a doc is created/removed** in `.claude/docs/`: update the table above.
- **When you discover a new risk area** not covered here: add a row.
- **Keep it short**: this file is loaded every session. Every line costs context.
