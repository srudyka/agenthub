## Purpose

Defines the separation of personal cell memory from governed shared retrieval.

## ADDED Requirements

### Requirement: Private memory and explicit sharing
Private conversation state and personal memory SHALL remain in the owning cell workspace/session store and SHALL NOT enter shared memory except through an explicit share proposal. The cell is authoritative for private content; Shared Memory Gateway is authoritative for accepted proposals and published claims.

#### Scenario: Unshared private content
- **WHEN** a user has not submitted an explicit share proposal
- **THEN** their private memory SHALL not appear in shared retrieval, embeddings, review queues, or another cell.

### Requirement: Authorized shared retrieval and degradation
The Shared Memory Gateway SHALL map workload identity to user and current Cognito groups and enforce current grants, scopes, classification, retention, status, and policy. Calls SHALL have bounded timeouts and circuit breaking; gateway unavailability SHALL preserve private-only cell operation.

#### Scenario: Sales access to HR
- **GIVEN** a Sales employee has no explicit valid grant for HR knowledge
- **WHEN** shared retrieval is requested
- **THEN** the gateway SHALL deny HR content and audit the decision.

#### Scenario: Gateway outage
- **WHEN** shared memory is unavailable or its timeout/circuit threshold is reached
- **THEN** the cell SHALL continue private operation, return a clear shared-memory-unavailable result, and emit health and audit events.

### Requirement: Derived embedding boundary
Embeddings SHALL be derived only from eligible, approved, current governed content and SHALL retain document, document-version, claim, and claim-version linkage. Private, unapproved, rejected, disputed, expired, deleted, superseded, and stale content SHALL not be embedded for ordinary shared retrieval; derived embeddings SHALL be excluded or invalidated when their linked content ceases to be eligible. Shared Memory Gateway records are authoritative for embedding eligibility and lifecycle.

#### Scenario: Ineligible embedding candidate
- **WHEN** private or non-current content is offered for embedding or retrieval
- **THEN** the gateway SHALL reject or exclude it, retain the lifecycle decision in audit history, and disclose no embedding-derived statement.
