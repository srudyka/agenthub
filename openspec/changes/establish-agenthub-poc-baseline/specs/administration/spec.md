## Purpose

Defines administrative authority, configuration ownership, and tamper-evident change records.

## ADDED Requirements

### Requirement: Single-source administration
The admin portal SHALL manage users/cells, Cognito group changes, policies, connector configuration metadata, retention, approvals, disputes, and cost visibility. Cognito remains authoritative for membership; the control-plane database is authoritative for department policy and governance state; Infisical is authoritative for runtime secrets and sensitive service configuration; and GitOps is authoritative for deployment configuration and non-overridable corporate ceilings. The portal SHALL not create a competing authority or expose secret values.

#### Scenario: Group administration
- **WHEN** an authorized administrator changes group membership through the portal
- **THEN** Cognito SHALL receive the authoritative change and later decisions SHALL use current Cognito membership.

### Requirement: Administrative audit record
Every administrative change SHALL record actor, timestamp, previous value, new value, correlation ID, target, decision, and policy/configuration version. Audit storage is authoritative for audit events.

#### Scenario: Policy change audit
- **WHEN** an authorized owner changes a department policy
- **THEN** the system SHALL persist the complete before/after record; a retry with the same idempotency key SHALL not create conflicting changes.

#### Scenario: Unauthorized administration
- **WHEN** an unprivileged user attempts an administrative action
- **THEN** the action SHALL be denied without mutation and audited.
