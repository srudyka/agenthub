## Purpose

Defines fail-closed, centrally brokered tools, egress, and sandbox infrastructure access.

## ADDED Requirements

### Requirement: Brokered tool and egress authorization
Cells SHALL have default-deny direct internet egress and SHALL request external actions through the Tool Broker. Corporate deny/ceiling and department policy determine access; policy records are authoritative. GitHub read and sandbox read-only AWS are in scope for POC implementation; email/calendar, Slack/Teams, and marketplace connectors are deferred.

#### Scenario: Denied egress
- **WHEN** a cell requests an unallowed tool, destination, method, or direct egress path
- **THEN** it SHALL fail closed, make no external call, and emit an audit event with decision and policy version.

#### Scenario: Broker timeout
- **WHEN** an allowed brokered tool call exceeds its configured timeout or its dependency fails
- **THEN** the broker SHALL return a bounded retry classification, SHALL not permit direct-egress fallback, and SHALL emit correlated audit and health events.

### Requirement: Approved sandbox writes
Infrastructure writes SHALL require explicit approval and a short-lived assumed role restricted to the sandbox environment; production accounts and mutations SHALL be unavailable. Approval record and role policy are authoritative.

#### Scenario: Unapproved write
- **WHEN** a user requests an infrastructure write without a valid approval or outside sandbox scope
- **THEN** the broker SHALL deny it, assume no write role, and audit actor, subject, decision, and correlation ID.
