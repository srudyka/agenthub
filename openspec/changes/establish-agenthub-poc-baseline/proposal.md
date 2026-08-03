## Why

AgentHub needs a reviewable POC contract before either repository begins implementation: each employee must receive an isolated OpenClaw cell while shared knowledge remains explicitly governed, attributable, and recoverable. This change turns the agreed architecture into testable requirements for a ten-user, synthetic-data-only AWS POC and explores SOC 2-aligned controls; it does not claim certification or production readiness.

## What Changes

- Establish the POC objective: validate isolated cells, governed shared memory, controlled models/tools, auditable administration, and scoped recovery in `us-east-2`.
- Define normative contracts for identity, routing, cell isolation/lifecycle, private and shared memory, ingestion, governance, administration, delivery, synthetic knowledge, and validation.
- Define two-repository ownership: `agenthub` owns platform contracts, architecture, deployment and control-plane artifacts; `agenthub-synthetic-knowledge` owns only the governed synthetic corpus and validation workflows, consuming the schema published by `agenthub` without submodules.
- Document POC-only cost/availability compromises: single region, one EKS cluster/node group, one NAT Gateway (a known single point of failure), peak two active cells, no regional recovery, and 15–30-second normal cold starts.
- Treat synthetic PII, customer, and financial classifications as classification-policy test data only. Real regulated data, real production credentials, production-account access, and production changes remain prohibited.
- Separate capabilities in scope for POC implementation (Cognito, isolated cells, Shared Memory Gateway, GitHub/S3 ingestion, model/tool gateways, sandbox-only AWS read/write approval path) from simulated controls and deferred extension points (email/calendar, Slack/Teams, connector marketplace, production-grade isolation and multi-region recovery).

### Scope and non-goals

This architecture/specification change creates no application code, Terraform, Helm, GitHub Actions, synthetic documents, or deployed services. It is not a production launch, SOC 2 certification, hostile-tenant isolation, public signup, employee billing, arbitrary skills, real-data processing, or multi-region disaster recovery.

### Measurable POC success criteria

- Ten administrator-created MFA users can be placed in authoritative Cognito groups, including multiple groups per user.
- Cross-cell access and cross-department retrieval are denied unless an explicit valid grant permits retrieval; corporate denies and ceilings prevail.
- An idle cell reaches zero replicas and normally becomes usable within 30 seconds when baseline worker capacity exists.
- Unapproved, rejected, disputed, expired, or stale shared claims are excluded from ordinary retrieval; returned statements carry validated provenance and versions.
- Replayed GitHub/S3 events yield one active claim per source-version identity; shared-memory outage preserves private-only cell operation.
- Model/tool/egress and sandbox infrastructure-write controls deny violations and produce required audit records.
- Shared-memory and control-plane component/AZ recovery exercises measure RTO no greater than 30 minutes and RPO no greater than 5 minutes; a miss fails the associated POC acceptance scenario and is reported as a miss.

### Dependencies, sequencing, and unresolved decisions

The follow-on work depends on stakeholder agreement on the diagrams, policy matrix, contracts, threat model, recovery plan, ADRs, and the results of explicitly listed spikes. Decisions intentionally unresolved here are: application language and UI framework; selected chat models/providers and budget thresholds; group/revocation propagation objective and cache TTL; department retention defaults; exact KEDA/WebSocket design; credential-bridge mechanism/rotation interval; ingestion identity mode; EFS RPO feasibility; pooling/performance limits; and exact corporate policy configuration values.

### POC capability disposition

| Disposition | Capabilities |
|---|---|
| In scope for POC implementation | Cognito identity/membership, token-derived routing, isolated cells/lifecycle, Shared Memory Gateway, explicit sharing/governance/provenance/disputes, GitHub/S3 ingestion, Model Gateway, Tool Broker, sandbox-only AWS approval path, administration/audit/observability, and scoped recovery validation. |
| Simulated by the POC | Synthetic PII/customer/financial classifications, synthetic departments and business records, sandbox infrastructure-write approval evidence, and unavailable/degraded dependency conditions used in validation. |
| Deferred | Production-grade/hostile-tenant isolation, real regulated data or production access, multi-region recovery, public signup, employee billing, arbitrary skills, full email/calendar/Slack/Teams, and a connector marketplace. |

## Capabilities

### New Capabilities

- `poc-scope`: POC boundaries, success measures, simulations, and deferrals.
- `identity-and-membership`: Cognito authentication, MFA, membership authority, and revocation handling.
- `tenant-routing`: Token-derived routing and public request isolation.
- `openclaw-cell-isolation`: Per-user cell, storage, identity, and network boundaries.
- `cell-lifecycle`: Cell provisioning, scale-to-zero, wake, and lifecycle audit behavior.
- `private-and-shared-memory`: Private-memory boundary, grants, retrieval, and private-only degradation.
- `knowledge-governance`: Publication, retention, classification, policy precedence, and ownership.
- `provenance-and-disputes`: Citation validation, version status, disputes, and supersession.
- `knowledge-ingestion`: GitHub/S3 ingestion, source versioning, idempotency, and failure handling.
- `model-governance`: Central model selection, credential isolation, quotas, and audit.
- `tool-and-egress-policy`: Tool Broker, egress denial, sandbox-only infrastructure approvals, and audit.
- `administration`: Authoritative administration, configuration ownership, and change auditability.
- `security-audit-and-observability`: Control-aligned audit, telemetry, privacy, and alerting requirements.
- `reliability-and-recovery`: Backup, restore, failover, degraded mode, RTO/RPO measurement.
- `infrastructure-and-delivery`: IaC/delivery contracts, deployment ownership, and POC cost boundaries.
- `synthetic-knowledge`: Synthetic corpus metadata, prohibited real data, and cross-repository validation.
- `poc-validation`: End-to-end POC acceptance evidence and reporting.

### Modified Capabilities

None; no existing main specifications are changed.

## Impact

`agenthub` will receive OpenSpec deltas and later owns architecture/ADR/threat-model/recovery/policy/contract documentation and implementation. `agenthub-synthetic-knowledge` will later receive synthetic corpus fixtures and validation that consume `agenthub/contracts/knowledge-document-v1.schema.json`. The proposal establishes review inputs for AWS, Cognito, EKS/KEDA, RDS PostgreSQL/pgvector, EFS, S3, queues, model/tool providers, GitHub, and CI/CD, without selecting unapproved implementation values.
