## Purpose

Defines scoped availability, backup, recovery, and honest objective measurement.

## ADDED Requirements

### Requirement: Scoped recovery objectives
For shared-memory and control-plane component or availability-zone failures, the POC SHALL target measured RTO no greater than 30 minutes and RPO no greater than 5 minutes; regional loss is deferred. RDS point-in-time recovery is the primary shared-memory recovery method. EFS personal-cell RPO feasibility SHALL be completed as an explicit architecture spike before implementation. If the EFS target cannot be met, the recovery plan SHALL contain an approved documented exception, alternative, owner, and expiry, and SHALL prohibit claiming that the EFS target was achieved.

#### Scenario: Recovery exercise
- **WHEN** a scoped restore or failover test completes
- **THEN** the report SHALL include actual RTO/RPO, component scope, backup/restore evidence, and SHALL mark the associated POC acceptance scenario failed rather than claim success when either target is missed.

#### Scenario: EFS target exception
- **WHEN** the EFS personal-cell RPO spike demonstrates that its target cannot be met
- **THEN** the POC SHALL record an approved documented exception and alternative and SHALL not report the EFS target as achieved.

### Requirement: Availability and degradation behavior
RDS Multi-AZ, versioned S3, EFS, queues, and one regional EKS cluster SHALL be designed for the POC’s component/AZ scope. Shared-memory loss SHALL degrade to private-only cells; retryable asynchronous work SHALL retain idempotency. One NAT Gateway is an accepted POC single point of failure.

#### Scenario: NAT or shared-memory outage
- **WHEN** the single NAT dependency or Shared Memory Gateway is unavailable
- **THEN** affected external/shared operations SHALL fail visibly and safely; private cell operation SHALL continue where its dependencies remain available.
