# Infrastructure — [Project Name]

> Map of where this project runs, which services it uses, and how it's organized.
> No secrets — only identifiers, orgs, accounts, regions, and URLs.
> Reference for developers and source of truth for automated context validation.

## Overview

[2-3 sentences on how the infra is organized. e.g. "Containerized service deployed to AWS ECS Fargate in us-east-1, RDS Postgres, S3 for assets, CloudFront in front of the API, Route53 for DNS."]

## Services and environments

> One `###` block per provider, platform, or infra component.
> No fixed format — adapt fields to the service. The point is that another
> developer can understand where things run and which identifiers to use
> without having to ask.
>
> Useful fields (use what applies):
> - Project/resource name or ID on the platform
> - Org, team, account, subscription (the "owner" identifier)
> - Region
> - Specific services or resources used
> - Relevant URLs (console, dashboard, endpoint)
> - Notes on quirks

### [Service name]
- [relevant fields for this service]

<!--
Common examples:

### AWS
- Account: 123456789012 (my-org)
- Region: us-east-1
- Services: ECS Fargate, RDS Postgres, S3, CloudFront, Route53, SES
- Console: https://us-east-1.console.aws.amazon.com/
- SSO start URL: https://my-org.awsapps.com/start

### GCP
- Project: my-project-123456
- Region: us-central1
- Services: Cloud Run, Cloud SQL (PostgreSQL), Cloud Build
- Console: https://console.cloud.google.com/home/dashboard?project=my-project-123456

### Azure
- Subscription: My Subscription (id: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
- Resource Group: rg-my-app
- Region: eastus
- Services: App Service, Azure SQL, Blob Storage

### GitHub
- Org: my-org
- Repository: my-org/my-app
- Actions: deploy.yml, ci.yml
- Branch protection on main: required reviews, required checks

### Cloudflare
- Account: my-account
- Services: DNS, Workers, R2
- Managed domains: myapp.com, myapp.dev

### Terraform
- Backend: S3 (bucket: my-org-tfstate, key: my-app/terraform.tfstate)
- Lock: DynamoDB (table: my-org-tflock)
- Modules: ./infra/modules

### Snowflake
- Account: my-org-acct123 (region: aws_us_east_1)
- Default role: TRANSFORMER
- Warehouses: WH_DEV (XS), WH_PROD (M)
- Databases: RAW, ANALYTICS, STAGING
- Connection name (snow CLI): prod_connection
- Console: https://app.snowflake.com/

### dbt
- Project: my_dbt_project
- Profile: my_profile (in ~/.dbt/profiles.yml)
- Targets: dev (default), prod
- Warehouse: WH_DEV / WH_PROD (Snowflake)
- Models output schemas: ANALYTICS.DEV_<user>, ANALYTICS.PROD

### Dagster
- Deployment: Dagster Cloud (org: my-org)
- Workspace file: workspace.yaml
- Code locations: ingestion, analytics
- Branch deployments: enabled on PRs
- URL: https://my-org.dagster.cloud/

### AWS S3 (key buckets)
- my-org-raw-data — landing zone for ingestion (lifecycle: 90d → Glacier)
- my-org-analytics — dbt artifacts, Dagster logs
- my-org-tfstate — Terraform state (versioned, locked via DynamoDB)

### Docker Compose (local)
- Compose file: docker-compose.yml
- Services: app, postgres, redis
- Ports: 3000 (app), 5432 (pg), 6379 (redis)

### Domains & DNS
- myapp.com → Route53 → CloudFront → ALB
- api.myapp.com → Route53 → API Gateway
-->

## Validation in /start

### Automated — CHECK-CONTEXT block

`check-context.sh` (called by `/start` step 0) reads the block below to compare the active CLI context with the expected one. Each line is `provider=value`. Providers not listed only get a connectivity check, no value comparison.

Supported keys: `aws`, `gcloud`, `az`, `gh`, `vercel`, `firebase`, `cloudflare`, `snowflake`, `dbt`, `dagster`.

<!-- CHECK-CONTEXT
# Uncomment and edit the lines that apply to this project:
# aws=123456789012
# gcloud=my-project-123456
# az=My Subscription
# gh=my-org
# vercel=my-team
# firebase=my-firebase-app
# cloudflare=my-account
# snowflake=prod_connection        # default Snowflake connection name
# dbt=my_profile/prod              # profile/target from dbt_project.yml
# dagster=my-org                   # Dagster Cloud organization
-->

### Manual (informational)
> Services without a CLI or without cross-context risk. Reference for developers, not auto-validated.

| Platform | What to check | How |
|---|---|---|
<!-- Examples:
| Docker local | Containers running | `docker compose ps` |
| Stripe | Correct account (live/test) | Dashboard |
-->

## Notes
> Any extra context that helps other developers.
> e.g. "Staging shares the same RDS instance with production — be careful with migrations."
