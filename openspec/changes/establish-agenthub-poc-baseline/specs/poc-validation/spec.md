## Purpose

Defines repeatable evidence that the POC contract works and reports its limits.

## ADDED Requirements

### Requirement: Mandatory acceptance evidence
The validation suite SHALL produce evidence for cell isolation, forged-routing denial, multi-group union, corporate-deny precedence, explicit sharing/reviewer privacy, approval and dispute quarantine, provenance/version currency, ingestion idempotency, model intersection/credential isolation, tool/egress/sandbox-write denial, private-only degradation, administrative audit completeness, cold-start objective, and recovery RTO/RPO measurement. The authoritative evidence is the versioned validation report correlated to audit records.

#### Scenario: Contract validation
- **WHEN** the POC validation run executes against the configured synthetic population
- **THEN** it SHALL mark every mandatory acceptance scenario pass, fail, blocked, or deferred with evidence and SHALL not silently omit a failed control.

#### Scenario: Recovery target miss
- **GIVEN** a shared-memory or control-plane recovery exercise measures RTO greater than 30 minutes or RPO greater than 5 minutes
- **WHEN** POC validation records the exercise
- **THEN** it SHALL mark the associated recovery acceptance scenario failed and SHALL not mark recovery successful merely because the miss was reported.

### Requirement: Failure and retry reporting
Validation SHALL exercise relevant timeout, retry, idempotency, stale-authorization, and degraded-mode paths and SHALL distinguish an unavailable dependency from an authorization denial.

#### Scenario: Repeated validation event
- **WHEN** a validation trigger is retried
- **THEN** it SHALL preserve one correlated result per logical run or explicitly version a rerun without overwriting prior evidence.
