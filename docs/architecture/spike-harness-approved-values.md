# Approved Spike-Harness Values

## Scope and topology

- Sandbox identifier: `agenthub-spike`.
- Region: `us-east-2`.
- Isolation: dedicated from any future POC feature environment.
- Operating model: create dependencies only for approved risk windows; do not operate a standing shared harness platform.
- Candidate dependency boundary: a two-AZ VPC; one temporary EKS cluster for KEDA/OpenClaw/EFS tests; temporary RDS PostgreSQL with pgvector for database/recovery tests; one EFS file system for the EFS spike; and a dedicated GitHub test repository/App. No portal, Shared Memory Gateway, or knowledge corpus is permitted.

## Execution, image, and evidence controls

- Test images must be immutable digests from an approved allowlist; upstream/vendor image selection is deferred to implementation-time provenance and vulnerability review. Floating tags are prohibited.
- GitHub Actions is the sole path for sandbox provisioning, probe deployment, probe execution, evidence capture, teardown, and any retained-resource disposition. Workflows use GitHub OIDC to assume only the sandbox-scoped role; local `terraform apply` and direct cloud deployment are prohibited.
- The AgentHub-owned bootstrap workflow is the one-time exception needed to establish that role: it retrieves `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` from Infisical at runtime, creates only the Terraform-state bucket(s), GitHub OIDC provider, and sandbox OIDC roles, and is disabled after a recorded successful handoff. It must not create the VPC or any harness dependency.
- `srudyka` supplies the required GitHub environment approval and remains accountable for the approved harness record, evidence, and teardown. Approval does not grant direct cloud credentials or override GitOps ceilings or sandbox identity policy.
- Every execution uses the approval-record correlation ID and produces the required evidence record.
- Evidence and audit references are retained for 365 days after resource teardown.

## Time, cost, and disposal controls

- Budget cap: US$750 for each 30-day harness window, with reviews at 50%, 80%, and 100%. New executions at the cap require an approved exception.
- Approval-record expiry: 7 days.
- Teardown: immediately after evidence capture. A resource may remain for at most 24 hours for active failure analysis only when a renewed approval record documents the justification.

These values do not authorize a workflow dispatch or provisioning. The separately approved implementation change may create the workflow and reviewable configuration, but each execution still requires its complete, unexpired harness record and GitHub environment approval. It must preserve the baseline's synthetic-only, sandbox-only, and EFS-exception boundaries.
