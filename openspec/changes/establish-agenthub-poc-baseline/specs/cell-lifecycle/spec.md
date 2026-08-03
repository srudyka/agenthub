## Purpose

Defines auditable lifecycle operations and normal scale-to-zero behavior for cells.

## ADDED Requirements

### Requirement: Scale-to-zero and wake
KEDA SHALL scale an idle cell between zero and one replica while baseline cluster worker capacity remains available. Under normal available capacity, a routed request to an idle cell SHALL become usable within 30 seconds; the timeout, retry, and outcome SHALL be observed and audited. Cell lifecycle desired state is authoritative in the control plane; runtime replica state is authoritative in Kubernetes.

#### Scenario: Normal cold start
- **GIVEN** an idle cell is at zero replicas and baseline worker capacity exists
- **WHEN** its authenticated user opens the cell
- **THEN** the platform SHALL start it and normally establish usable service within 30 seconds.

#### Scenario: Capacity or wake timeout
- **WHEN** a cell cannot wake before the configured bound
- **THEN** the platform SHALL return a retry-safe unavailable result, avoid cross-cell routing, record latency/cause, and audit the lifecycle failure.

### Requirement: Idempotent lifecycle commands
Create, wake, suspend, and retry requests SHALL use an idempotency key and SHALL not create more than one active cell for a Cognito `sub`.

#### Scenario: Retried wake
- **WHEN** the same wake request is delivered repeatedly
- **THEN** the platform SHALL report the same logical operation and retain one cell mapping.
