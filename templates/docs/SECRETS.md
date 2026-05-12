# Secrets — [Project Name]

> **This file must be gitignored.** Never commit actual secret values.
> Use this as an inventory of which secrets exist, what they're for, and where they live.

## Inventory
| Name | Used by | Source of truth | Notes |
|---|---|---|---|
| DATABASE_URL | api | AWS Secrets Manager (`prod/db`) |  |
| STRIPE_SECRET_KEY | api | AWS Secrets Manager (`prod/stripe`) | Rotated quarterly |

## Local development
[How to populate `.env.local` for dev. Reference scripts if any.]

## Rotation
[Schedule / process for rotating each secret class.]
