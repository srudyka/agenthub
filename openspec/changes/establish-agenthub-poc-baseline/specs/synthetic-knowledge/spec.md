## Purpose

Defines safe, governed synthetic knowledge and cross-repository validation contracts.

## ADDED Requirements

### Requirement: Synthetic corpus ownership and metadata
`agenthub-synthetic-knowledge` SHALL own corporate and Sales, Marketing, HR, and Engineering synthetic corpus content and fixtures; `agenthub` SHALL own `contracts/knowledge-document-v1.schema.json`. Every document SHALL validate owner, scope, department, classification, retention_days, and schema_version. Synthetic classifications SHALL be treated as policy exercises, never evidence that real regulated data is permitted.

#### Scenario: Malformed fixture
- **WHEN** a document omits required metadata or violates the authoritative schema
- **THEN** validation SHALL fail and ingestion SHALL not publish it.

### Requirement: Governance test fixtures
The synthetic corpus SHALL provide disputed, expired, unauthorized, and malformed fixtures plus interdepartmental negative authorization cases. Git-backed corpus versions SHALL use Git SHA as source version; generated or real data are prohibited.

#### Scenario: Unauthorized fixture
- **WHEN** a Sales identity queries an HR-only synthetic fixture without a valid grant
- **THEN** retrieval SHALL deny it and the validation result SHALL record the isolation evidence.
