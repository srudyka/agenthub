# AgentHub POC Ownership Matrix

| Decision or asset | Authoritative owner | Non-authoritative consumers |
|---|---|---|
| User identity, MFA, group membership | Amazon Cognito | Router, gateways, admin portal |
| Cell route for a request | Tenant router derived from Cognito `sub` | Browser and cells receive no client-selected mapping |
| Corporate denies and ceilings; deployment configuration | GitOps in `agenthub` | Control plane enforces but cannot override |
| Department runtime policy, connector configuration, approvals, disputes | Control-plane database | Admin portal manages it; gateways enforce it |
| Runtime secrets and sensitive service configuration | Infisical | Platform workloads read only approved scopes; cells receive no secret access |
| Source document bytes and source-version identity | Versioned S3 / Git commit SHA | PostgreSQL records metadata and relationships |
| Document/claim/version, citation, embedding eligibility, publication/dispute state | Shared Memory Gateway PostgreSQL | Cells retrieve only authorized results |
| Private conversation and personal memory | Owning cell workspace/session storage | Never shared without proposal and approval |
| Application decision audit | Structured audit store | CloudWatch is operational telemetry only |
| AWS API audit | CloudTrail | Security review consumes it |
| Knowledge-document schema | `agenthub/contracts/knowledge-document-v1.schema.json` | `agenthub-synthetic-knowledge` validates against it |
| Synthetic corpus and fixtures | `agenthub-synthetic-knowledge` | `agenthub` ingestion/validation consumes it |

No setting has two authoritative sources. The admin portal initiates Cognito changes but does not become the membership authority; department policy remains bounded by GitOps corporate ceilings.
