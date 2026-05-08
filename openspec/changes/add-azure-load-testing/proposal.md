## Why

Performance and reliability are critical for the CraftedSpecially API running in Kubernetes. We need to validate that the API can handle expected load and identify bottlenecks before they impact production. Azure Load Testing provides a managed solution to conduct realistic load tests against the API endpoint without requiring infrastructure in the cluster itself.

## What Changes

- Create an Azure Load Testing resource provisioned via Bicep
- Define load test scenarios with configurable user loads and ramp-up profiles
- Create load test scripts that exercise the CraftedSpecially API running in AKS
- Add monitoring and reporting of load test results via Application Insights
- Document how to execute tests against the running Kubernetes deployment

## Capabilities

### New Capabilities
- `azure-load-testing-infrastructure`: Azure Load Testing resource provisioned via Bicep, supporting multiple named test configurations and result aggregation
- `api-load-test-definition`: Load test scripts (JMeter/Apache format) defining realistic API scenarios, user profiles, and success criteria for the Kubernetes-deployed API

### Modified Capabilities
<!-- Existing capabilities whose REQUIREMENTS are changing (not just implementation).
     Only list here if spec-level behavior changes. Each needs a delta spec file.
     Use existing spec names from openspec/specs/. Leave empty if no requirement changes. -->

## Impact

- **Infrastructure Code**: New Bicep modules in `infra/modules/continuous_validation/load_testing/` (Azure resource only)
- **Test Definitions**: New load test files (JMeter scripts) in `infra/load_tests/`
- **Observability**: Load test results integrated with existing Application Insights instance
- **Deployment**: Adds Azure Load Testing resource provisioning to the Bicep deployment
- **Kubernetes**: No changes required to existing Kubernetes manifests or deployments; load testing targets the public API endpoint
- **APIs**: No breaking changes to existing APIs; load testing operates independently against running deployments
