## Purpose

Defines centrally governed model access without provider credentials in user cells.

## ADDED Requirements

### Requirement: Intersection model selection
The Model Gateway SHALL permit a user to select only models allowed by both current corporate ceiling and department policy, and SHALL enforce configured quotas, rate limits, usage measurement, and cost attribution. The POC SHALL use `amazon.nova-lite-v1:0` as primary Bedrock chat model, `amazon.nova-micro-v1:0` as fallback, and `amazon.titan-embed-text-v2:0` as its fixed embedding model, subject to implementation-time regional availability verification. It SHALL enforce a US$200 monthly model budget cap, emit alerts at 50, 80, and 100 percent of that cap, and deny new model requests once the cap is reached. GitOps corporate policy and control-plane department policy are authoritative inputs.

#### Scenario: Disallowed model
- **WHEN** a user selects a model absent from either allowlist or above a ceiling
- **THEN** the gateway SHALL deny it, invoke no provider, and audit policy versions and correlation ID.

#### Scenario: Monthly budget cap
- **GIVEN** measured monthly model usage has reached US$200
- **WHEN** a user requests additional model usage
- **THEN** the gateway SHALL deny the request and retain the corresponding threshold alert and audit event.

### Requirement: Credential isolation
Cells SHALL not contain model-provider credentials. Bedrock access SHALL use workload identity; any external provider key SHALL remain in Infisical and be used only by the gateway through the least-privilege secret scope. A fixed platform embedding model is in scope for POC implementation; the exact model remains configuration.

#### Scenario: Provider outage
- **WHEN** a selected provider times out or fails
- **THEN** the gateway SHALL return a bounded error, record usage/outcome, and not disclose provider credentials.
