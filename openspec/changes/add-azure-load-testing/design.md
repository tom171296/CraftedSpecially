## Context

The CraftedSpecially API is deployed in Azure Kubernetes Service (AKS) using Kubernetes manifests managed by ArgoCD. The existing infrastructure includes observability (Application Insights), networking, and Kubernetes resources. Load testing will target the public API endpoint of the running Kubernetes deployment without requiring any changes to the cluster itself.

Azure Load Testing is a managed service external to Kubernetes that integrates with existing Azure Monitor and Application Insights, making it a natural fit for the CraftedSpecially architecture.

## Goals / Non-Goals

**Goals:**
- Provide a managed load testing solution that targets the Kubernetes-deployed API
- Support multiple configurable test scenarios (baseline, spike, ramp-up profiles)
- Integrate test results with Application Insights for unified observability
- Enable teams to execute load tests on-demand against running deployments
- Document realistic API usage patterns in test scripts for future regression detection

**Non-Goals:**
- In-cluster load testing tools (e.g., k6, Locust) - using managed Azure service instead
- Real-time continuous load testing - executed on-demand in this iteration
- Chaos engineering integration - covered by existing chaos testing deployment in cluster
- Load testing for Kubernetes infrastructure components - scope limited to API endpoints
- Multi-region load testing - single region deployment in this iteration

## Decisions

### Decision 1: Test Framework & Format
**Choice**: Apache JMeter format (`.jmx` files)
**Rationale**: Azure Load Testing natively supports JMeter; widely used in the industry; supports complex request scenarios, correlation, and assertions; no need to run anything in-cluster
**Alternatives Considered**:
- k6 in Kubernetes: Would require in-cluster resources; adds complexity to deployments
- cURL scripts: Too simplistic for realistic scenarios
- Custom scripts: Would require significant development and maintenance overhead

### Decision 2: Load Testing Resource Location
**Choice**: Bicep-provisioned Azure Load Testing resource as external service
**Rationale**: Load testing is a platform service that monitors the API; no Kubernetes changes needed; integrates with existing Azure infrastructure
**Alternatives Considered**:
- In-cluster load testing tool: Adds resource contention; complicates cluster management
- Separate testing cluster: Unnecessary overhead for on-demand testing

### Decision 3: Test Targets
**Choice**: Target the public API endpoint exposed by the Kubernetes Ingress/Gateway
**Rationale**: Tests realistic user experience; no special cluster access needed; can run from anywhere
**Configuration**: API endpoint URL parameterized for different environments (dev, staging, prod)

### Decision 4: Test Triggers
**Choice**: Manual on-demand execution via Azure CLI or Azure Portal
**Rationale**: Safer for initial implementation; allows teams to validate before critical deployments
**Future**: Can be expanded to automated triggers on deployment or scheduled intervals
**Alternatives Considered**:
- Automatic on every deployment: Risk of blocking deployments due to test failures
- Scheduled execution: Harder to correlate test results with code changes

### Decision 5: Test Configuration
**Choice**: Multiple named test profiles stored in Bicep parameters
**Rationale**: Allows different scenarios without code changes; configuration managed alongside infrastructure
**Supported Profiles**:
- `smoke-test`: Single user, validates connectivity and basic flows via public IP
- `load-test`: 100 users ramped over 2 minutes, 10 minute sustain against public IP
- `spike-test`: 500 users instantaneous, 5 minute duration targeting public IP

### Decision 6: Results & Monitoring
**Choice**: Azure Load Testing sends metrics to Application Insights; dashboards created for viewing results
**Rationale**: Leverages existing observability infrastructure; unified metrics with application performance data
**Metrics Tracked**: Response time (p50, p95, p99), error rate, throughput, resource utilization
**Correlation**: Metrics tagged with test execution metadata for easy correlation with API performance

## Risks / Trade-offs

| Risk | Mitigation |
|------|-----------|
| Load tests consume quota/costs | Implement cost controls; use small profile sizes in non-production testing |
| Test data pollution in monitoring | Use distinct test user agents; filter in Application Insights queries |
| Unrealistic test scenarios | Validate test scripts with production traffic patterns; iterate based on results |
| API endpoint changes break tests | Maintain test scripts in version control; document endpoint contracts |
| Authentication token expiry during long-running tests | Implement token refresh logic in JMeter test scripts |
| Public IP accessibility required | Public IP must be reachable from Azure Load Testing service (typically no issues for public endpoints) |
| Port/protocol mismatch | Must verify correct port and protocol (http vs https) in public IP configuration |

## Migration Plan

1. Create Bicep modules for Azure Load Testing resource
2. Deploy Load Testing resource to non-production environments first
3. Define JMeter test scripts with authentication and realistic scenarios
4. Validate test execution and result collection
5. Document how to run tests and interpret results
6. Deploy Load Testing resource to production resource group

## Open Questions

- What is the public API endpoint URL for accessing the Kubernetes-deployed service? (Answer: Specified in specs phase)
- What authentication method will be used for tests - test user account, service principal, API key? (Answer: TBD in specs)
- Should test results be automatically compared against baseline metrics? (Answer: Phase 2 enhancement)
