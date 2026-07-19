# VerifyHub Infrastructure

Terraform-managed AWS infrastructure for VerifyHub, a B2B KYC verification platform.

This repo owns how VerifyHub is built, run, secured, and shipped on AWS. Application
code lives in /app (provided stub, not modified here — see app/README.md for a note
on stub availability).

## Repo layout

infra/
  modules/       Reusable building blocks (VPC, ECS service, RDS, S3, SQS, etc.)
                 Environment-agnostic. No hardcoded env names or account IDs.
  environments/
    dev/          Root module: wires modules together for dev, dev-sized config
    staging/      Same wiring, staging-sized config
    prod/         Same wiring, prod-sized config
  global/
    state-backend/  One-time bootstrap: creates the S3 bucket + DynamoDB lock table
.github/workflows/  CI/CD: fmt, validate, plan-on-PR, apply-on-merge
docs/diagrams/       Editable architecture + request-flow diagrams
app/                 Provided application stub (untouched)
DECISIONS.md         Key decisions, tradeoffs, assumptions, what's next

## Prerequisites

- Terraform >= 1.7
- AWS CLI configured with credentials for the target account
- GitHub Actions secrets configured for CI (see .github/workflows/)

## How to run terraform plan per environment

(Filled in fully once Phase 1 - state backend - is done)

cd infra/environments/dev
terraform init -backend-config=backend.hcl
terraform plan -var-file=terraform.tfvars

Same pattern for staging and prod — only the directory changes.

## Status

Building in phases. Current: Phase 0 complete.

## Delivery flow

1. Open a PR touching infra/** — GitHub Actions runs fmt check, validate, and plan
   for dev/staging/prod, posting each plan as a PR comment.
2. A human reviews the plan output alongside the code diff, approves the PR.
3. Merge to main triggers apply: dev first, then staging, then prod (each a separate
   job, sequential via `needs`).
4. prod requires a manual approval click (GitHub Environment protection rule) before
   its apply runs, even post-merge — the last human checkpoint before production.

No one applies from a local machine against real infrastructure; every change is
visible in a PR diff and a plan comment before it happens.
