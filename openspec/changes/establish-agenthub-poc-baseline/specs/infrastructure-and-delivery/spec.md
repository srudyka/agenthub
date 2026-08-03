## Purpose

Defines the POC infrastructure/delivery contract and ownership without provisioning it.

## ADDED Requirements

### Requirement: Constrained AWS topology
The POC SHALL target one `us-east-2` region across two AZs, one EKS cluster, one managed node group (initial min/desired 1, max 2), KEDA cell scaling, RDS PostgreSQL Multi-AZ with pgvector, EFS access points, versioned SSE-KMS S3, queues, TLS/WAF edge, and one NAT Gateway. It SHALL not include Karpenter, OpenSearch, a second region, cross-region EFS, or multi-region databases. Deployment configuration is authoritative in GitOps.

#### Scenario: Cost-bound review
- **WHEN** an architecture change requests excluded capacity or regional redundancy
- **THEN** it SHALL require a new approved decision; the baseline SHALL retain the documented cost/availability consequence.

### Requirement: Delivery control contract
Terraform SHALL be the IaC contract with separate bootstrap/foundation/platform/data states and no secrets/state in Git. GitHub Actions SHALL use AWS OIDC, distinct plan/apply roles, protected-main environment approval and fresh merge-commit plans; delivery SHALL use immutable signed image digests, scanning/SBOM, Argo CD deployment watch, path filters, drift detection, branch protection, and CODEOWNERS. These are in scope for later POC implementation changes.

#### Scenario: Unapproved delivery
- **WHEN** a deployment or infrastructure apply lacks protected-main approval or a fresh approved plan
- **THEN** the delivery control SHALL reject it and record the decision.
