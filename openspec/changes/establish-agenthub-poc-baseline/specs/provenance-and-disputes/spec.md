## Purpose

Defines verifiable citations, version currency, dispute quarantine, and supersession.

## ADDED Requirements

### Requirement: Server-validated provenance
Every returned shared statement SHALL pass server-side citation/provenance validation and include claim ID, source URL/S3 reference, source owner, knowledge owner, source and publication timestamps, source document version, claim version, classification, and current status. PostgreSQL claim/version records and versioned S3 source records are authoritative; prompt-only validation is prohibited.

#### Scenario: Citation validation
- **WHEN** a candidate lacks a valid current source, owner, timestamp, or version
- **THEN** it SHALL not be returned and the validator result SHALL be auditable.

#### Scenario: Stale version
- **WHEN** a superseded, expired, deleted, or stale source version is queried as current
- **THEN** the gateway SHALL exclude it from ordinary retrieval and expose its historical version only to authorized audit/governance workflows.

#### Scenario: Deleted source
- **WHEN** an authoritative source document or source version is deleted or becomes unavailable
- **THEN** the gateway SHALL mark dependent claims non-current, invalidate or exclude linked embeddings from ordinary retrieval, retain auditable history, and process repeated deletion events idempotently.

### Requirement: Dispute and supersession
An employee SHALL be able to dispute a shared claim. A dispute SHALL immediately mark it disputed and remove it from ordinary retrieval; authorized owner/governance review SHALL restore it or create a versioned superseding claim without mutating prior history.

#### Scenario: Immediate quarantine
- **WHEN** a valid dispute is submitted
- **THEN** ordinary retrieval SHALL stop returning that claim before review completes, while original claim, approvals, dispute, and audit history remain available to authorized reviewers.
