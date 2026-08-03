## Purpose

Defines the per-employee OpenClaw boundary and its non-hostile-tenant limitations.

## ADDED Requirements

### Requirement: Dedicated cell boundary
The POC SHALL allocate one complete OpenClaw Gateway/cell per employee, with a dedicated namespace, Deployment, service account/workload identity, EFS access point/PVC, gateway credential, quotas, resource limits, and default-deny NetworkPolicy. No mutually untrusted users SHALL share a gateway. Kubernetes namespace isolation is in scope for POC implementation as a boundary, not VM-grade isolation.

#### Scenario: Cross-cell attempt
- **GIVEN** a Sales employee's cell attempts another cell's namespace, storage, service account, credential, session, or private memory
- **WHEN** the target is requested
- **THEN** the request SHALL be denied, no target data SHALL be disclosed, and an audit/security event SHALL be emitted.

### Requirement: Cell credential boundary
Cell credentials SHALL be scoped to their cell and rotated through the approved bridge design; model-provider and production credentials SHALL be unavailable inside all cells. Credential authority is Secrets Manager/workload identity, not cell configuration.

#### Scenario: Credential exfiltration attempt
- **WHEN** a cell requests a model-provider or production secret directly
- **THEN** it SHALL receive no credential, the request SHALL fail closed, and the attempt SHALL be auditable.
