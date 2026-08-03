## Purpose

Defines centrally governed model access without provider credentials in user cells.

## ADDED Requirements

### Requirement: Intersection model selection
The Model Gateway SHALL permit a user to select only models allowed by both current corporate ceiling and department policy, and SHALL enforce configured quotas, rate limits, usage measurement, and cost attribution. GitOps corporate policy and control-plane department policy are authoritative inputs; exact model list, providers, and budgets remain unresolved deployment configuration.

#### Scenario: Disallowed model
- **WHEN** a user selects a model absent from either allowlist or above a ceiling
- **THEN** the gateway SHALL deny it, invoke no provider, and audit policy versions and correlation ID.

### Requirement: Credential isolation
Cells SHALL not contain model-provider credentials. Bedrock access SHALL use workload identity; any external provider key SHALL remain in Secrets Manager and be used only by the gateway. A fixed platform embedding model is in scope for POC implementation; the exact model remains configuration.

#### Scenario: Provider outage
- **WHEN** a selected provider times out or fails
- **THEN** the gateway SHALL return a bounded error, record usage/outcome, and not disclose provider credentials.
