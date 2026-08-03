## Purpose

Defines governed publication, ownership, classification, retention, and precedence.

## ADDED Requirements

### Requirement: Proposal and approval gate
An employee SHALL explicitly select “share this” (or equivalent unambiguous action), preview the exact excerpt, and select an allowed scope/classification. Submission SHALL create a proposal only; a department knowledge owner or governance reviewer SHALL approve or reject it before embedding or retrieval. Proposal/approval records are authoritative in Shared Memory Gateway.

#### Scenario: Reviewer privacy
- **WHEN** a reviewer opens a proposal
- **THEN** they SHALL receive only the proposed excerpt and required provenance/classification/scope context, not unrelated private conversation content.

#### Scenario: Rejected claim
- **WHEN** a proposal is rejected or remains unapproved
- **THEN** no corresponding claim SHALL be retrievable or embedded and the decision SHALL be audited.

#### Scenario: Repeated proposal or reviewer decision
- **WHEN** a proposal submission or reviewer decision is retried with the same idempotency key
- **THEN** the gateway SHALL retain one logical proposal and one terminal decision for its version, reject conflicting decisions, and audit the correlated outcome.

### Requirement: Policy precedence and retention
Corporate GitOps policy defines non-overridable denies and ceilings; department runtime policy in the control-plane database may configure only values within those ceilings; valid grants are additive. Shared retention SHALL be configurable from 30 to 365 days subject to corporate limits; department defaults are unresolved configuration. Audit retention SHALL be 365 days.

#### Scenario: Expiry
- **WHEN** a document or claim reaches retention expiry
- **THEN** it SHALL not be returned as current, its status/history SHALL remain auditable, and retrying expiration processing SHALL be idempotent.
