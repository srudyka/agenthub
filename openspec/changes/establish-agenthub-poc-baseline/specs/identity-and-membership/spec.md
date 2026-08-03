## Purpose

Defines authoritative user authentication, group membership, and authorization freshness.

## ADDED Requirements

### Requirement: Cognito identity authority
Amazon Cognito SHALL be the authoritative source for user identity and department, team, and privileged-role membership. The POC SHALL permit administrator-created users only and require MFA; the control-plane database may mirror identity only as non-authoritative metadata.

#### Scenario: Authentication
- **GIVEN** an administrator-created user completes MFA
- **WHEN** Cognito issues a valid token
- **THEN** the platform SHALL use its `sub` as the user identity and audit authentication.

#### Scenario: Stale membership
- **GIVEN** a membership cache is older than the yet-to-be-decided propagation boundary or a revocation is indicated
- **WHEN** an authorization decision is requested
- **THEN** the platform SHALL refresh Cognito membership or fail closed and audit the stale-authorization result.

### Requirement: Membership decision semantics
The authorization service SHALL evaluate all current Cognito groups. Valid memory grants are additive; explicit corporate/security/tool/egress denies and corporate ceilings override grants. Cognito and versioned policy records are the authoritative decision inputs. For each shared-memory retrieval or mutation and privileged action, a token-embedded group claim alone SHALL NOT authorize access after the approved membership-propagation boundary; the service SHALL obtain a Cognito membership snapshot no older than that boundary or fail closed. The propagation boundary/cache TTL remains an approved design decision, but a pending or detected revocation SHALL deny access until current Cognito membership is confirmed.

#### Scenario: Multi-group union
- **GIVEN** a user is in multiple Cognito groups with distinct valid memory grants
- **WHEN** shared-memory access is evaluated
- **THEN** the result SHALL include the union of grants not excluded by a deny or ceiling.

#### Scenario: Corporate deny
- **GIVEN** a department grant permits content and corporate policy denies it
- **WHEN** access is evaluated
- **THEN** the request SHALL be denied and audited with both policy versions.

#### Scenario: Revoked user with a still-valid token
- **GIVEN** a user presents an unexpired token containing a group removed in Cognito
- **WHEN** the request is evaluated after the approved propagation boundary or revocation indication
- **THEN** the service SHALL refresh membership or deny access, SHALL not rely on the stale token claim, and SHALL audit the revocation-aware decision.
