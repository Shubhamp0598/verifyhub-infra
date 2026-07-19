# Decisions Log

Key decisions, tradeoffs, assumptions, and what I'd do next — recorded as the repo is built.

---

## Phase 0 — Repo structure

**Decision:** Split into infra/modules (reusable, environment-agnostic) and
infra/environments/{dev,staging,prod} (thin root modules supplying config only).

**Why:** Standard pattern for "one codebase, many environments." Modules hold logic
(how to build a VPC). Environment folders hold data (how big, how many). A new
environment is a new folder + tfvars file — no copy-pasted resource blocks to drift.

**Assumption:** The /app stub referenced in the assignment was not included in the
materials I received (only the PDF brief). I'm proceeding by defining a generic
container contract (health check path, port, env vars) that the ECS module is built
against, documented in app/README.md, so swapping in a real stub later is a config
change, not a redesign.

**Assumption:** Single AWS account for dev/staging/prod, isolated via separate state
files, VPCs, and IAM boundaries rather than separate AWS accounts. Revisited under
Security — for regulated KYC/PII data, account-per-environment via AWS Organizations
would be the production-grade choice; noted as a "what I'd do next."

**Region:** ap-south-1 (Mumbai).

---

## Phase 1 — networking + state

State bucket + lock table bootstrapped once with local state, then every env's
Terraform points at it via backend.hcl (per-env key). New env = new folder + tfvars,
no module changes.

3-tier subnets per AZ: public (ALB/NAT), private-app (ECS), private-data (RDS/cache,
no internet route). Per-AZ NAT gateways instead of one shared NAT — costs more but an
AZ outage doesn't take out the other AZ's egress. Could go single-NAT for dev to save
cost; kept symmetric for now.

Region: us-east-1.
