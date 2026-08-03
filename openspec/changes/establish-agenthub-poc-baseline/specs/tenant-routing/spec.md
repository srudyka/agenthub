## Purpose

Defines trusted routing from authenticated employees to their private cells.

## ADDED Requirements

### Requirement: Token-derived cell routing
The edge and tenant router SHALL validate Cognito tokens and derive cell identity solely from the authenticated `sub`. A public hostname may expose `/`, `/api`, `/cell`, and `/webhooks/github`; individual cells SHALL remain private. Cognito is authoritative for identity and the router mapping is authoritative for the request route.

#### Scenario: Forged cell identifier
- **GIVEN** a valid public request contains another user's cell or tenant identifier in path, header, query, body, or cookie
- **WHEN** the router handles it
- **THEN** it SHALL ignore or reject the supplied identifier, route only to the caller-derived cell, and audit the attempt.

#### Scenario: Invalid token
- **WHEN** a token is absent, expired, invalid, or cannot be validated before the configured timeout
- **THEN** the router SHALL deny the request without contacting a cell and audit the denial.
