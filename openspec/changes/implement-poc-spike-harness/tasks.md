## 1. Pre-implementation controls

- [x] 1.1 [agenthub] Consult Terraform provider documentation, inspect version constraints/lockfile, and document the reviewed module/resource choices for the approved sandbox boundary.
- [x] 1.2 [agenthub] Create the approved harness-record and evidence-record configuration surfaces with correlation IDs, expiry, budget thresholds, teardown authorization, immutable workflow reference, protected GitHub environment, approved dispatch inputs, and non-secret Infisical configuration references.
- [x] 1.3 [agenthub] Select and review immutable allowlisted test-image digests, the dedicated GitHub test repository/App configuration, protected environment, GitHub OIDC sandbox-role trust boundary, and approved Infisical project/environment and workload-authentication boundary.

## 2. Disposable sandbox implementation

- [ ] 2.1 [agenthub] Implement the AgentHub-owned one-time bootstrap workflow and Terraform state bucket(s), GitHub OIDC provider/roles, then the `agenthub-spike` two-AZ sandbox network, GitHub-OIDC-only sandbox identity boundary, cost/teardown tagging, and protected GitHub Actions plan/apply/teardown workflow using Terraform.
- [ ] 2.2 [agenthub] Implement temporary EKS/KEDA, EFS, and approved synthetic probe workloads for the KEDA, Cognito, EFS, and cold-start risk windows.
- [ ] 2.3 [agenthub] Implement temporary RDS PostgreSQL with pgvector and GitHub-test integration for the database and connector risk windows.
- [ ] 2.4 [agenthub] Implement workflow-mediated evidence capture, idempotent result recording, audit correlation, timeout/retry, budget review, and teardown/retention enforcement.

## 3. Verification and disposal

- [ ] 3.1 [agenthub] Run focused sandbox-only workflow tests for direct-deployment denial, scope denial, production-boundary denial, expiry, budget cap, replay/idempotency, timeout, and teardown behavior.
- [ ] 3.2 [agenthub] Execute the approved architecture-risk windows, retain evidence for 365 days, and record ADR/change recommendations.
- [ ] 3.3 [agenthub] Verify teardown after each window and require a renewed approval for any 24-hour failure-analysis retention.
