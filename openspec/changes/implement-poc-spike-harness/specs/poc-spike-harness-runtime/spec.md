## Purpose

Defines the executable, disposable sandbox behavior for collecting AgentHub architecture-spike evidence without exposing production systems or data.

## ADDED Requirements

### Requirement: Approved sandbox execution
The runtime SHALL execute only a complete, unexpired approval record in the `agenthub-spike` sandbox in `us-east-2`. It SHALL enforce the approved two-AZ dependency boundary, immutable approved image digests, GitHub Actions as the sole deployment and operational path, GitHub OIDC sandbox role, seven-day approval expiry, and the US$750 per-30-day budget cap with review thresholds at 50, 80, and 100 percent. The approval record, GitOps ceiling, GitHub workflow/environment configuration, and sandbox identity policy are authoritative for their respective decisions.

#### Scenario: Expired or over-budget execution
- **GIVEN** an approval is expired or the budget cap has been reached without an approved exception
- **WHEN** execution is requested
- **THEN** the runtime SHALL deny execution and create an audit event with correlation ID.

#### Scenario: Direct deployment attempt
- **GIVEN** a principal attempts a local Terraform apply, direct cloud deployment, or direct teardown
- **WHEN** the sandbox identity policy evaluates the request
- **THEN** it SHALL deny the request, permit the operation only from the approved GitHub OIDC role and protected workflow, and create an audit event with correlation ID.

#### Scenario: One-time AWS bootstrap
- **GIVEN** the approved AgentHub bootstrap workflow is awaiting its first OIDC handoff
- **WHEN** it retrieves `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` from Infisical through GitHub OIDC
- **THEN** it SHALL create only the Terraform-state bucket(s), GitHub OIDC provider, and sandbox OIDC roles; it SHALL create no VPC, harness dependency, or workload; and it SHALL record the handoff for disabling the bootstrap workflow.

### Requirement: Evidence and disposal enforcement
The runtime SHALL capture versioned synthetic-only evidence for each execution, idempotently link replays to one active result, and teardown dependencies immediately after evidence capture. Retention for active failure analysis SHALL not exceed 24 hours without a renewed approval record. No execution SHALL create AgentHub feature services, a corpus, production access, or a production claim.

#### Scenario: Timed-out execution
- **GIVEN** an execution times out or fails
- **WHEN** the runtime finalizes it
- **THEN** it SHALL record an indeterminate or failed result, preserve audit/evidence references, and execute teardown or an approved 24-hour retention decision.

#### Scenario: Production boundary attempt
- **GIVEN** a workload requests a production credential, endpoint, data source, or unapproved image
- **WHEN** the runtime evaluates it
- **THEN** it SHALL fail closed, prevent execution, and audit the denial.

### Requirement: Sandbox secret and configuration authority
The runtime SHALL use Infisical as the authoritative source for sandbox runtime secrets and sensitive service configuration. GitHub Actions variables may carry only non-secret Infisical location or identity references; no secret value may be committed to Git, written to a GitHub Actions variable, or emitted in workflow or workload logs. The selected Infisical workload authentication mechanism and project/environment boundary are authoritative only after approval.

#### Scenario: Secret retrieval outside the approved boundary
- **GIVEN** a cell, unapproved workflow, or workload requests an Infisical secret outside its approved scope
- **WHEN** Infisical and workload identity evaluate the request
- **THEN** access SHALL be denied, no secret value SHALL be disclosed, and the denial SHALL be recorded with a correlation ID.
