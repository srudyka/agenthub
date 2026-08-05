## Context

This implementation realizes the approved harness values and the contracts in `establish-poc-spike-harness`. It is a temporary sandbox measurement system, not an AgentHub feature environment.

## Goals / Non-Goals

**Goals:** provision the minimum approved sandbox dependencies through GitHub Actions, execute synthetic probe workloads through the protected workflow with scoped OIDC identity, capture evidence, and teardown.

**Non-Goals:** employee traffic, feature services, shared memory, corpus ingestion, production access, local/direct deployment, or production readiness.

## Decisions

- Use Terraform with the repository's required provider/module review and separate state boundaries; GitHub Actions is the only plan, apply, deployment, execution, evidence-capture, teardown, and retention-disposition path. No workflow apply occurs without the approved record, a fresh workflow plan, and protected GitHub environment approval.
- Bootstrap the GitHub OIDC provider, sandbox OIDC roles, and encrypted/versioned Terraform-state bucket(s) through an AgentHub-owned `dev` workflow that retrieves `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` from Infisical at runtime. This is a one-time exception: it may not create a VPC or any harness dependency, is disabled after successful OIDC handoff, and is never copied from or run in `lab01-infra`.
- Scope the sandbox to a two-AZ VPC and create EKS/EFS/RDS-pgvector/GitHub-test dependencies only for approved risk windows.
- Use immutable allowlisted image digests and a sandbox-scoped GitHub OIDC role; `srudyka` supplies the protected GitHub environment approval and does not execute cloud changes from a local credential.
- Use Infisical as the authoritative source for sandbox runtime secrets and sensitive service configuration. GitHub environment variables may identify non-secret Infisical project/environment configuration but SHALL not contain any secret value; the exact Infisical hosting and workload authentication mechanism remain approval inputs.
- Enforce a US$750/30-day cap, seven-day approvals, immediate teardown, and a maximum 24-hour approved failure-analysis hold.

## Risks / Trade-offs

- [Temporary dependencies exceed cost] → budget thresholds and immediate teardown.
- [Harness becomes feature runtime] → deny feature services/corpus/employee traffic by scope and review.
- [Evidence is incomplete] → mark indeterminate and block ADR/feature approval.

## Migration Plan

Run the AgentHub bootstrap workflow once to establish the OIDC roles and remote state, then disable it after recording the handoff. Provision only after the normal GitHub workflow creates a fresh Terraform plan for an approved harness record and the protected GitHub environment approves it. Run one risk window at a time; retain evidence, teardown, and feed results to ADR review. Roll back only through the same GitHub workflow, destroying the validated sandbox resources in the approved record.
