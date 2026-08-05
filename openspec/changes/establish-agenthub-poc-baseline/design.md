## Context

See [proposal.md](proposal.md) for motivation and [specs](specs) for behavior. This greenfield POC is a single-region, synthetic-only exploration for ten Cognito users (peak two active cells), not a production system or SOC 2 certification. No language, UI framework, model/provider list, budget, group-cache TTL, or department retention default is selected by this design.

## Goals / Non-Goals

**Goals:** establish a reviewable architecture for isolated user cells, governed shared knowledge, policy-enforced model/tool access, auditable administration, and measured component/AZ recovery.

**Non-Goals:** implementation, provisioning, real regulated data, production access, public signup, VM-grade tenant isolation, multi-region DR, and full email/calendar/Slack/Teams/connectors.

The baseline itself does not provision infrastructure. A separately approved spike-harness change is the only pre-feature implementation exception: it may create disposable, sandbox-only dependencies and test workloads required to measure a named architecture risk. It may not introduce AgentHub feature services, real data, corpus content, production credentials or access, or a production claim. The approved harness change record is authoritative for its risk scope, owner, budget, evidence, and teardown plan.

## Decisions

### System context and trust boundaries

```mermaid
flowchart LR
  B[Browser] -->|TLS + Cognito token| E[WAF / Edge / Tenant Router]
  B --> C[Cognito]
  E -->|sub-derived route, short-lived bridge| X[Private OpenClaw Cell]
  X -->|MCP, workload identity| M[Shared Memory Gateway]
  X -->|brokered only| T[Tool Broker]
  X -->|brokered only| G[Model Gateway]
  M --> P[(RDS PostgreSQL + pgvector)]
  M --> S[(Versioned KMS S3)]
  I[GitHub / upload events] --> Q[Queue + ingestion]
  Q --> M
  G --> MP[Bedrock / external model provider]
  T --> XP[GitHub / sandbox AWS]
```

Trust boundaries: browser-to-edge is public TLS; Cognito is the identity boundary; edge/router is the only public-to-cell routing boundary; cells are private per-user namespaces; gateways are platform policy-enforcement boundaries; RDS/S3/EFS are private data boundaries; connectors/providers are external boundaries. The router accepts identity only from a validated Cognito token and derives the cell from `sub`; no client cell identifier is trusted. Gateway workload identity is mapped to current Cognito membership before every sensitive decision. The bridge credential is a signed JWT, audience- and `sub`-bound with a five-minute lifetime; its signing key rotates every 30 days. Integration behavior remains subject to the required spike.

### AWS deployment and network/credential boundaries

```mermaid
flowchart TB
  Internet --> W[Internet-facing ALB/WAF TLS]
  subgraph VPC[us-east-2 / two AZs]
    W --> R[Edge + tenant router]
    subgraph EKS[One EKS cluster, node group 1..2]
      R --> CELLS[Private cell namespaces / KEDA 0..1]
      R --> APPS[Admin/control-plane and gateways]
      APPS --> ING[Ingestion workers]
    end
    CELLS --- EFS[EFS access points]
    APPS --- RDS[RDS PostgreSQL Multi-AZ + pgvector]
    APPS --- S3[Versioned SSE-KMS S3]
    ING --- SQS[SQS/equivalent]
    EKS --> NAT[One NAT Gateway]
  end
  NAT --> Ext[GitHub, model/tool providers]
  EKS -. Pod Identity .-> IAM[IAM roles]
    APPS -. least-privilege runtime secret/config reads .-> IF[Infisical]
```

Cells possess only cell-scoped workload identity, EFS access point, and rotated gateway credential; they have default-deny network egress and no model-provider, production, or cross-cell credentials. Infisical is authoritative for runtime secrets and sensitive service configuration; only approved platform workloads may read the smallest required scope through a selected least-privilege authentication mechanism. Cells cannot read Infisical secrets. GitOps remains authoritative for deployment configuration and corporate ceilings, while the control-plane database remains authoritative for department policy and governance state. TLS protects public and service paths; KMS protects AWS storage services. One NAT Gateway is an accepted cost reduction and single point of external-egress failure.

### Principal sequences

```mermaid
sequenceDiagram
 participant U as Browser
 participant C as Cognito
 participant R as Edge/router
 participant X as Cell
 U->>C: MFA sign-in
 C-->>U: validated token (sub, groups)
 U->>R: /cell + token
 R->>R: validate; derive cell from sub
 R->>X: private route + bridge credential
 X->>C: refresh membership when required
 X-->>U: cell session
```

```mermaid
sequenceDiagram
 participant U as User
 participant R as Router
 participant K as KEDA/Kubernetes
 participant X as Cell
 U->>R: authenticated /cell
 R->>K: request derived cell
 K->>X: scale 0 to 1
 X-->>R: ready or bounded timeout
 R-->>U: usable normally <=30s; otherwise retry-safe unavailable
```

```mermaid
sequenceDiagram
 participant U as Employee
 participant X as Cell
 participant M as Shared Memory
 participant V as Reviewer
 U->>X: explicit share this
 X-->>U: exact excerpt + scope/classification preview
 U->>M: submit proposal
 M->>V: excerpt + required context only
 V->>M: approve/reject
 M->>M: approved only: create/embed claim
 M-->>U: audited result
```

```mermaid
sequenceDiagram
 participant X as Cell
 participant M as Memory Gateway
 participant C as Cognito/policy
 X->>M: retrieval with workload identity
 M->>C: current groups + policy
 M->>M: scope/status/retention + citation validation
 M-->>X: statements with provenance, or denial
```

```mermaid
sequenceDiagram
 participant U as Employee
 participant M as Memory Gateway
 participant V as Owner/governance
 U->>M: dispute claim
 M->>M: disputed; remove ordinary retrieval
 M->>V: immutable history + dispute
 V->>M: restore or versioned supersession
```

```mermaid
sequenceDiagram
 participant X as Cell
 participant M as Shared Memory
 X->>M: bounded retrieval
 M--x X: timeout/outage
 X->>X: open circuit; private-only mode
 X-->>X: continue private conversation
```

### Authorization and data model

Policy evaluation is: authenticate Cognito `sub`; resolve current Cognito groups; combine applicable valid memory grants; apply corporate deny/ceiling; then department policy inside ceiling; evaluate scope, classification, retention, claim/version status, and resource constraints. An explicit deny always wins; a valid grant adds only otherwise-permitted access. Corporate ceilings live in GitOps, department runtime policies in the control-plane database, membership in Cognito, and publication/dispute state in Shared Memory Gateway.

High-level entities and relations: `user(sub)` ↔ `group`; `user` → one `cell`; `policy` has scope/version/source; `document` → immutable `document_version` → `claim` → immutable `claim_version`; `proposal` → `approval|rejection`; `dispute` targets claim/version; `retrieval_citation` records returned claim/version/source validation; `connector_configuration`, `model_policy`, and `tool_policy` reference policy versions; `audit_event` references actor, subject, resource, decision, timestamp, and correlation ID. Original document bytes are S3 objects; metadata/embeddings/governance/audit references are PostgreSQL.

| Store | Authoritative ownership / purpose |
|---|---|
| Cognito | identity, MFA, membership |
| RDS PostgreSQL | control-plane runtime policies; documents/versions, claims/versions, proposals, approvals, disputes, citations, audit references, pgvector |
| S3 | versioned KMS-encrypted original documents and upload source versions |
| EFS | owning cell's private workspace/session state only |
| Infisical | runtime secrets and sensitive service configuration, including provider, connector, bridge, and sandbox-integration material; never cell-readable |
| CloudWatch | operational logs/metrics/traces; not the application decision source |
| CloudTrail | AWS API audit source |

### Measurable POC outcome traceability

The eventual POC validation report SHALL use the following stable evidence identifiers; each row maps a proposal outcome to its capability contract and scenario.

| Measurable outcome | Capability / requirement | Scenario | Eventual test evidence |
|---|---|---|---|
| Ten MFA users receive authoritative groups | `identity-and-membership` / `Cognito identity authority` | `Authentication` | `POC-ID-01` identity/group evidence |
| Cross-cell and unauthorized department access is denied | `openclaw-cell-isolation` / `Dedicated cell boundary`; `private-and-shared-memory` / `Authorized shared retrieval and degradation` | `Cross-cell attempt`; `Sales access to HR` | `POC-AUTH-01` isolation denial evidence |
| Multiple-group grants are additive and deny prevails | `identity-and-membership` / `Membership decision semantics` | `Multi-group union`; `Corporate deny` | `POC-AUTH-02` policy-precedence evidence |
| Forged public cell identifier cannot alter routing | `tenant-routing` / `Token-derived cell routing` | `Forged cell identifier` | `POC-ROUTE-01` forged-route evidence |
| Idle cell normally wakes within 30 seconds | `cell-lifecycle` / `Scale-to-zero and wake` | `Normal cold start`; `Capacity or wake timeout` | `POC-LIFE-01` cold-start timing evidence |
| Private content is shared only through review | `private-and-shared-memory` / `Private memory and explicit sharing`; `knowledge-governance` / `Proposal and approval gate` | `Unshared private content`; `Reviewer privacy`; `Rejected claim` | `POC-MEM-01` sharing/reviewer evidence |
| Shared statements are current and provenance-validated | `provenance-and-disputes` / `Server-validated provenance` | `Citation validation`; `Stale version`; `Deleted source` | `POC-PROV-01` citation/version evidence |
| Disputes quarantine claims | `provenance-and-disputes` / `Dispute and supersession` | `Immediate quarantine` | `POC-GOV-01` dispute evidence |
| GitHub/S3 ingestion is protected and idempotent | `knowledge-ingestion` / `Idempotent asynchronous ingestion`, `GitHub webhook authenticity` | `Replayed event`; `Forged webhook`; `Processing failure` | `POC-ING-01` delivery/retry evidence |
| Model access and credentials are governed | `model-governance` / `Intersection model selection`, `Credential isolation` | `Disallowed model`; `Credential exfiltration attempt` | `POC-MODEL-01` selection/secret-boundary evidence |
| Tool/egress and sandbox writes fail closed | `tool-and-egress-policy` / `Brokered tool and egress authorization`, `Approved sandbox writes` | `Denied egress`; `Broker timeout`; `Unapproved write` | `POC-TOOL-01` broker/approval evidence |
| Shared-memory loss preserves personal cell operation | `private-and-shared-memory` / `Authorized shared retrieval and degradation` | `Gateway outage` | `POC-DEGRADE-01` private-only evidence |
| Privileged/governance actions are auditable | `administration` / `Administrative audit record`; `security-audit-and-observability` / `Structured control audit` | `Policy change audit`; `Denial evidence` | `POC-AUDIT-01` complete audit-record evidence |
| Recovery meets stated scope or fails honestly | `reliability-and-recovery` / `Scoped recovery objectives`; `poc-validation` / `Mandatory acceptance evidence` | `Recovery exercise`; `Recovery target miss`; `EFS target exception` | `POC-REC-01` measured RTO/RPO and exception evidence |

### Recovery and cost posture

RDS Multi-AZ and PITR are primary shared-memory/control-plane recovery. For their component/AZ failures, the objectives are measured RTO no greater than 30 minutes and RPO no greater than 5 minutes. A miss fails the associated acceptance scenario; reporting a miss is not success. Versioned S3 supports source recovery. EFS personal-cell RPO feasibility is an explicit pre-implementation architecture spike with a target RPO no greater than 30 minutes. The approved temporary exception uses non-durable personal-cell workspaces, expires 90 days after the first EFS-enabled POC deployment, and prohibits claiming the EFS target achieved; its owner, rationale, and closure requirements are documented in `docs/architecture/efs-personal-cell-rpo-exception.md`. Regional loss is out of scope. Single region, one cluster/node group, baseline node capacity, RDS Multi-AZ, no OpenSearch/Karpenter/second region, and a single NAT reduce POC cost but limit capacity/resilience. Shared-memory failure is intentionally degraded to private-only, never a reason to lose the personal cell.

### Proposed ADRs and required spikes

Proposed ADRs: (1) per-user OpenClaw Gateway boundary; (2) Cognito sub-derived routing/credential bridge; (3) shared-memory PostgreSQL/pgvector plus S3 provenance; (4) precedence split between GitOps ceilings, control-plane governance, and Infisical runtime secrets/configuration; (5) GitHub identity mode; (6) KEDA scale-to-zero transport; (7) single-NAT POC compromise; (8) EFS private-state recovery posture; (9) Terraform state split and OIDC delivery controls; (10) Infisical hosting, authentication, project/environment layout, and secret-rotation posture.

Required analysis/spikes, each with a pass/fail evidence artifact before implementation: OpenClaw WebSocket behavior behind KEDA HTTP scale-to-zero (including reconnect); Cognito bridge credential rotation; cell mapping/group-cache invalidation and revocation propagation target; cold-start under node pressure; server-side citation enforcement bypass attempts; EFS backup/restore RPO; pgvector latency/connection-pool limit at POC load; GitHub App versus per-user OAuth identity/permissions; NAT failure impact; and proof that runtime configuration cannot override GitOps corporate ceilings.

### Threat model summary

Principal threats are forged routing, token replay/stale group authorization, cross-namespace/storage access, private-content oversharing, poisoned/stale sources, citation bypass, provider/connector credential theft, tool/egress abuse, webhook replay, privileged-policy tampering, and availability failures. Mitigations are token-derived routes, refresh/fail-closed authorization, per-cell identities and default-deny networking, explicit review, server validation/versioning, gateways/secrets isolation, idempotency, immutable audit records, approval gates, WAF/TLS/KMS/least privilege, and measured recovery/degradation. This is SOC 2-aligned control exploration, not certification.

## Risks / Trade-offs

- [Single NAT / one cluster] → documented availability limits; exercise degraded modes and do not claim HA.
- [Namespace rather than VM isolation] → synthetic-only POC and explicit non-hostile-tenant limitation.
- [Unknown bridge/KEDA/EFS behavior] → implementation is gated on the named spikes.
- [Policy freshness vs latency] → do not choose cache TTL; define propagation objective during decision review and fail closed when unsafe.

## Migration Plan

This is a planning-only baseline: review/approve the artifacts, create the listed architecture documents/contracts/scaffolding, complete spikes, then implement only through small follow-on OpenSpec changes. Rollback is removal of unapproved planning artifacts; no runtime migration exists.

## Open Questions

Exact chat model identifiers after regional availability/cost confirmation and measured EFS/pgvector/KEDA limits remain decision inputs. Approved values are TypeScript with React/Next.js; a 60-second maximum membership-revocation propagation objective with a 30-second cache TTL/immediate portal invalidation; a signed JWT bridge with a five-minute lifetime and 30-day signing-key rotation; a central read-only GitHub App with a 15-minute polling fallback; 30/90/90/180-day HR/Sales/Marketing/Engineering retention defaults under a 365-day ceiling; p95 retrieval no greater than two seconds at the POC peak; one reversible sandbox mutation cleaned up within 15 minutes; and a US$200 monthly model cap with 50/80/100-percent alerts and denial at the cap.
