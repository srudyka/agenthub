## Purpose

Defines governed, versioned, retry-safe GitHub and portal-upload ingestion.

## ADDED Requirements

### Requirement: Allowed sources and source identity
The POC SHALL implement GitHub allowlisted repository/branch/path ingestion and portal pre-signed S3 uploads for Markdown, text, and PDF. GitHub commit SHA and S3 Version ID SHALL be authoritative source versions; document metadata SHALL preserve owner, scope, department, classification, retention, schema version, deletion, and expiration state.

#### Scenario: Unauthorized source
- **WHEN** a webhook, poll, or upload references a source outside its allowlist or unsupported format
- **THEN** ingestion SHALL reject it without publication and audit the denial.

### Requirement: Idempotent asynchronous ingestion
Webhook-driven GitHub updates, configured polling fallback, and queued S3 events SHALL be retry-safe and idempotent by source identity/version. Replayed delivery SHALL not create duplicate active documents or claims; transient failure SHALL record attempt state and retry under the configured policy.

#### Scenario: Replayed event
- **WHEN** identical GitHub webhooks or S3 events are delivered repeatedly
- **THEN** the pipeline SHALL produce at most one active claim for the source version and record correlated attempts.

#### Scenario: Processing failure
- **WHEN** parsing, queue delivery, or embedding fails
- **THEN** the source SHALL not become published, failure SHALL be observable/auditable, and a retry SHALL not bypass approval.

### Requirement: GitHub webhook authenticity
The public GitHub webhook endpoint SHALL validate the configured GitHub delivery authenticity mechanism before queueing work, SHALL reject invalid, expired, or replayed delivery identity, and SHALL not invoke authenticated employee cell routing. The configured GitHub App or OAuth integration is authoritative for source identity.

#### Scenario: Forged webhook
- **WHEN** a public GitHub webhook has invalid authenticity evidence or a replayed delivery identity
- **THEN** ingestion SHALL reject it before queueing, SHALL create no document or claim, and SHALL audit the provider-delivery decision.
