# Spike-harness supply-chain and identity review

## Review status

Approved configuration selection for task 1.3 of
`implement-poc-spike-harness`. This selection does not authorize a workflow
dispatch, Terraform apply, cloud provisioning, or a GitHub App installation.

## Image allowlist

| Purpose | Approved immutable image | Source and review basis |
| --- | --- | --- |
| OpenClaw WebSocket/KEDA and private-workspace risk windows | `ghcr.io/openclaw/openclaw:2026.5.26-slim@sha256:ae7ff536446f1bbb57ea51b9b21097d8f299d30d683dcd72644973bc0522f3b3` | Official `openclaw/openclaw` GHCR package; manifest digest resolved directly on 2026-08-04. |

Floating tags are prohibited. Any additional probe image, including a custom
synthetic test image, must have an allowlist entry containing its immutable
digest, source-provenance review, and vulnerability-review evidence before a
workflow may use it.

## GitHub deployment and test-integration boundary

- Deployment/workflow repository: `srudyka/agenthub` only.
- Workflow GitHub environment: `dev`; it must be protected for `main` and
  require approval by `srudyka` before apply, execution, teardown, or any
  retained-resource disposition.
- GitHub OIDC subject for the sandbox AWS role and Infisical identity:
  `repo:srudyka/agenthub:environment:dev`.
- AWS OIDC audience: `sts.amazonaws.com`; the eventual role is sandbox-only.
  Its account ID is discovered and audited at runtime rather than checked
  against a preconfigured allowlist under the approved exception.
- GitHub test-integration repository: private
  `srudyka/lab01-infra`, read-only, `main` branch only.
- A dedicated `agenthub-spike` GitHub App must be created before connector
  execution. Its installation scope is only `srudyka/agenthub` and
  `srudyka/lab01-infra`; its initial permissions are Metadata: read and
  Contents: read. It receives no write, administration, workflow, secret, or
  organization permission.

The existing lab deployment workflow is an OIDC/Infisical implementation
reference only. AgentHub implements its own workflow in `srudyka/agenthub`.
Its one-time bootstrap job may retrieve static AWS bootstrap credentials from
Infisical at runtime only to establish remote state and AgentHub GitHub OIDC
roles; all later jobs use the created OIDC roles.

## Infisical boundary

The `dev` environment uses the non-secret references copied from
`srudyka/lab01-infra`:

- `ENV_NAME`
- `INFISICAL_MECHID_ID`
- `INFISICAL_ORG_SLUG`
- `INFISICAL_PROJECT_ID`
- `INFISICAL_PROJECT_SLUG`

The existing machine identity is reused, but its OIDC authentication policy
must explicitly permit `repo:srudyka/agenthub:environment:dev` and must retain
any required existing lab subject separately. It must not use Universal Auth,
a static client secret, or a GitHub Actions secret. The identity has access
only to the existing `dev` project context and the new `/agenthub-spike/`
secret path, including the one-time `/agenthub-spike/bootstrap/` AWS
credentials. The workflow requires `id-token: write` and obtains short-lived
Infisical access through GitHub OIDC; its exact token TTL and project role
remain reviewable configuration inputs.

## Verification required before dispatch

Before a workflow can be approved for a risk window, reviewers must verify:

1. the GitHub `dev` protection rule and `main` branch policy are active;
2. the AWS role trust policy exactly matches the selected GitHub OIDC subject
   and audience, and the workflow records the runtime-discovered account ID;
3. the Infisical identity admits the selected subject and no broader subject;
4. the referenced image digest matches the allowlist and current vulnerability
   review; and
5. the GitHub App installation and permissions match the least-privilege scope.
