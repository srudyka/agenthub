## Why

The approved spike-harness contract now needs a minimal, disposable sandbox implementation to produce runtime evidence for AgentHub's ten architecture risks. Without it, feature implementation would proceed without required KEDA, Cognito, EFS, pgvector, GitHub, NAT, and policy-precedence evidence.

## What Changes

- Implement the approved `agenthub-spike` sandbox boundary in `us-east-2`, including only dependencies required by approved risk windows.
- Implement approval-record enforcement, sandbox-scoped execution, evidence capture, timeout/retry/idempotency handling, and teardown controls.
- Implement the approved two-AZ VPC, temporary EKS/EFS/RDS-pgvector/GitHub-test-integration dependency boundary only as needed by the named spikes.
- Enforce immutable approved image digests, GitHub Actions-only sandbox execution through GitHub OIDC and protected environment approval by `srudyka`, a US$750 per-30-day window cap with 50/80/100% reviews, seven-day approvals, immediate teardown, and a 24-hour approved failure-analysis retention maximum.
- Implement only synthetic/generated probe inputs; no AgentHub feature services, knowledge corpus, real data, production credentials/access, or any local/direct deployment path.

### Dependencies and non-goals

Requires approved sandbox AWS access, a protected GitHub environment and OIDC role, a test GitHub repository/App, selected immutable image digests after provenance/vulnerability review, and the required Terraform provider/module review. This change is not production infrastructure, a feature deployment, a general test platform, or a replacement for the final POC validation.

## Capabilities

### New Capabilities

- `poc-spike-harness-runtime`: Disposable sandbox harness execution, evidence capture, budget/expiry/teardown enforcement, and safe measurement of approved architecture risks.

### Modified Capabilities

None.

## Impact

`agenthub` infrastructure, test, and documentation areas will receive the harness implementation. `agenthub-synthetic-knowledge` is unaffected; no corpus content or validation workflow is introduced. The resulting evidence feeds ADRs and later feature-change gates, but does not itself claim production readiness or SOC 2 certification.
