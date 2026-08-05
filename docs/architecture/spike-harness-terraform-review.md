# Spike-harness Terraform review

## Decision status

This is the required pre-implementation provider and module review for the
disposable `agenthub-spike` sandbox. It is not an approval to provision the
sandbox.

The repository contains no existing `*.tf` files, Terraform version
constraint, `required_providers` block, or `.terraform.lock.hcl`. Version
selection therefore remains an implementation decision that must be pinned in
the first Terraform configuration and recorded in its generated lockfile.

## Reviewed sources

The Terraform MCP public Registry review on 2026-08-04 found these candidate
versions:

| Boundary | Candidate | Reviewed version | Intended use |
| --- | --- | --- | --- |
| Provider | `hashicorp/aws` | `6.57.1` | `us-east-2` sandbox resources, scoped assumed role, allowed AWS account guard, and default tags. |
| Network | `terraform-aws-modules/vpc/aws` | `6.6.1` | Two-AZ sandbox VPC only. |
| Kubernetes | `terraform-aws-modules/eks/aws` | `21.24.1` | Temporary EKS boundary for approved KEDA, OpenClaw WebSocket, Cognito-bridge, and EFS probes. |
| Database | `terraform-aws-modules/rds/aws` | `7.2.0` | Temporary PostgreSQL boundary for the pgvector probe only. |
| File storage | `terraform-aws-modules/efs/aws` | `2.2.0` | Temporary EFS boundary for the personal-cell recovery probe only. |

The AWS provider review confirmed support for a scoped `assume_role` block,
`allowed_account_ids`, and provider-level `default_tags`. The approved
bootstrap exception deliberately disables the expected-account allowlist: the
workflow discovers and audits its account ID at runtime for resource naming and
evidence, but does not compare it to a preconfigured account ID. Credentials
must never be embedded in configuration. A real plan remains required to
validate compatibility, cost, quotas, and resource changes.

## Boundary rules for code generation

- Terraform state and resources must be isolated to the `agenthub-spike`
  sandbox; no production account, endpoint, credential, backend, or data
  source may be referenced.
- The provider must pin an explicit compatible version. The runtime-discovered
  account ID is recorded in the approval/evidence record but is not allowlisted
  by the provider under the approved exception. The source role and target
  role ARN remain unresolved inputs; neither is inferred here.
- Every resource must receive the approved owner, correlation ID, approval
  expiry, budget-window, purpose, and teardown tags.
- EKS, EFS, RDS, GitHub integration, and synthetic probes are optional modules:
  each may be enabled only by an unexpired approved harness record for its
  named risk window.
- EFS is a feasibility experiment. It must not claim achievement of the
  30-minute personal-cell RPO target unless its measurement evidence meets the
  approved criteria; otherwise the recorded exception controls.
- `terraform fmt`, `terraform init -backend=false`, and `terraform validate`
  are required after configuration generation. A GitHub Actions workflow must
  produce a fresh plan against a concrete approved record before its protected
  environment can authorize apply. Direct local `terraform apply` is
  prohibited.

## Deferred configuration inputs

The following values are deliberately not selected by this review and must be
approved before Terraform can be applied: source and target IAM role ARNs,
state backend, VPC CIDR and AZs, EKS and PostgreSQL
versions/sizes, image digests, GitHub test repository and App identifiers,
and the exact enabled risk window.
