## Purpose

Defines the POC infrastructure/delivery contract and ownership without provisioning it.

## ADDED Requirements

### Requirement: Constrained AWS topology
The POC SHALL target one `us-east-2` region across two AZs, one EKS cluster, one managed node group (initial min/desired 1, max 2), KEDA cell scaling, RDS PostgreSQL Multi-AZ with pgvector, EFS access points, versioned SSE-KMS S3, queues, TLS/WAF edge, and one NAT Gateway. It SHALL not include Karpenter, OpenSearch, a second region, cross-region EFS, or multi-region databases. Deployment configuration is authoritative in GitOps.

#### Scenario: Cost-bound review
- **WHEN** an architecture change requests excluded capacity or regional redundancy
- **THEN** it SHALL require a new approved decision; the baseline SHALL retain the documented cost/availability consequence.

### Requirement: Delivery control contract
Terraform SHALL be the IaC contract with separate bootstrap/foundation/platform/data states and no secrets/state in Git. GitHub Actions SHALL use AWS OIDC, distinct plan/apply roles, protected-main environment approval and fresh merge-commit plans; delivery SHALL use immutable signed image digests, scanning/SBOM, Argo CD deployment watch, path filters, drift detection, branch protection, and CODEOWNERS. Infisical SHALL be the authoritative source for runtime secrets and sensitive service configuration; GitHub Actions variables SHALL contain no secret value. These are in scope for later POC implementation changes.

#### Scenario: Unapproved delivery
- **WHEN** a deployment or infrastructure apply lacks protected-main approval or a fresh approved plan
- **THEN** the delivery control SHALL reject it and record the decision.

### Requirement: One-time delivery bootstrap exception
The POC MAY use an AgentHub-owned, protected GitHub bootstrap workflow to retrieve `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` from Infisical at runtime solely to create the encrypted/versioned Terraform-state bucket(s), the GitHub OIDC provider, and sandbox-scoped GitHub OIDC plan/apply roles. The bootstrap workflow SHALL use the `dev` environment, require approval, use no GitHub secret or variable for either key, create no VPC, EKS, EFS, RDS, application, or workload resource, and disable itself after a successful handoff to the OIDC roles. All later infrastructure actions SHALL use the AgentHub GitHub OIDC roles.

#### Scenario: Bootstrap scope violation or repeat
- **GIVEN** the bootstrap workflow requests a non-bootstrap resource or runs after a recorded successful OIDC handoff
- **WHEN** the workflow evaluates its approval and scope
- **THEN** it SHALL fail closed, create no resource, and record an audit event with the correlation ID.

### Requirement: Disposable spike-harness delivery boundary
A separately approved spike-harness change MAY precede AgentHub feature implementation only to provision the minimum disposable sandbox infrastructure and test workloads required for named architecture spikes. Its approved change record is authoritative for resource scope, budget, owner, required evidence, and teardown. All POC provisioning, deployment, operational, and teardown actions SHALL use a protected GitHub Actions workflow with GitHub OIDC to a sandbox-only role; direct local or cloud-console changes SHALL be denied and audited. The harness SHALL be isolated from production, use no real data or production credentials, and SHALL NOT establish an AgentHub application service or production-ready environment.

#### Scenario: Harness completion
- **WHEN** a named spike completes or its approval expires
- **THEN** the harness owner SHALL retain the pass/fail evidence and execute the approved teardown plan; any retained resource SHALL require a renewed approved harness record.
