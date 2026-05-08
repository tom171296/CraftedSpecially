## 1. Public IP Discovery and Configuration

- [x] 1.1 Identify the public IP address of the Kubernetes service/ingress exposing the CraftedSpecially API
- [x] 1.2 Determine the protocol (HTTP/HTTPS) for accessing the API via public IP
- [x] 1.3 Verify the port number used by the service (80, 443, or custom port)
- [x] 1.4 Test connectivity to the public IP endpoint from external location
- [x] 1.5 Document the public IP endpoint URL format (e.g., `http://<IP>:<PORT>`)

## 2. Bicep Infrastructure Setup

- [x] 2.1 Create `infra/modules/continuous_validation/load_testing/` directory structure
- [x] 2.2 Create `load_testing.bicep` main module file with parameters for environment, naming conventions, public IP
- [x] 2.3 Create `load_testing_resource.bicep` to provision Azure Load Testing resource
- [x] 2.4 Implement Application Insights integration for metrics collection
- [x] 2.5 Implement Azure Key Vault integration for secure credential storage
- [x] 2.6 Add Network configuration if needed for private/restricted access
- [x] 2.7 Add RBAC role assignments for managed identities

## 3. Bicep Parameters and Configuration

- [x] 3.1 Add load testing parameters to `infra/params.bicepparam` file including public IP endpoint
- [x] 3.2 Add parameters for API public IP address, port, and protocol
- [x] 3.3 Define smoke-test profile parameters (1 user, 2 minute duration, public IP target)
- [x] 3.4 Define load-test profile parameters (100 users ramped over 2 min, 10 min sustain, public IP target)
- [x] 3.5 Define spike-test profile parameters (500 users instant, 5 min duration, public IP target)
- [x] 3.6 Add environment-specific overrides (dev, staging, prod) with corresponding public IP addresses
- [x] 3.7 Create variables.bicep file for Load Testing naming conventions and constants

## 4. Main Template Integration

- [x] 4.1 Update `CraftedSpecially.bicep` to include load testing module
- [x] 4.2 Add conditional logic for load testing resource deployment based on environment
- [x] 4.3 Pass required parameters (public IP, Application Insights connection, Key Vault reference) to load testing module
- [x] 4.4 Test Bicep template validation and syntax checking

## 5. Load Test Scripts - Core Setup

- [x] 5.1 Create `infra/load_tests/` directory structure
- [x] 5.2 Create `infra/load_tests/README.md` documenting test suite structure and execution via public IP
- [x] 5.3 Create JMeter test suite base configuration template targeting public IP endpoint
- [x] 5.4 Implement parameterization for public IP address, port, and protocol
- [x] 5.5 Implement parameterization for authentication credentials retrieval from Key Vault

## 6. Load Test Scripts - Authentication

- [x] 6.1 Create `infra/load_tests/auth-common.jmx` with shared authentication logic for public IP access
- [x] 6.2 Implement token acquisition for test user account
- [x] 6.3 Implement token refresh logic for extended test runs against public IP
- [x] 6.4 Implement error handling for authentication failures
- [x] 6.5 Create documentation for test user account setup and permissions

## 7. Load Test Scripts - API Scenarios

- [x] 7.1 Create `infra/load_tests/api-health-check.jmx` for health endpoint test via public IP
- [x] 7.2 Create `infra/load_tests/api-core-operations.jmx` for main API workflows via public IP
- [x] 7.3 Implement request/response assertions for status codes
- [x] 7.4 Implement response time assertions (p95 < 1000ms for interactive endpoints)
- [x] 7.5 Implement response content validation (JSON structure, required fields)
- [x] 7.6 Add data extraction logic for correlation (auth tokens, resource IDs)
- [x] 7.7 Add parameterized data files (CSV) for realistic variation across requests

## 8. Load Test Scripts - Monitoring and Logging

- [ ] 8.1 Configure request/response logging for debug scenarios with sampling
- [ ] 8.2 Configure performance metrics collection (connect time, first byte, response time)
- [ ] 8.3 Implement error logging with full context (status, message, response body)
- [ ] 8.4 Configure metrics export to Application Insights custom tables
- [ ] 8.5 Test metrics appear correctly in Application Insights during test run

## 9. Test Documentation

- [ ] 9.1 Create test scenario documentation in `infra/load_tests/api-health-check/README.md`
- [ ] 9.2 Create test scenario documentation in `infra/load_tests/api-core-operations/README.md`
- [ ] 9.3 Document prerequisites for each test (test user account, permissions, data setup, public IP access)
- [ ] 9.4 Document expected behavior and success criteria for each scenario
- [ ] 9.5 Create troubleshooting guide for common test failures

## 10. Deployment and Testing

- [ ] 10.1 Deploy Bicep templates to development environment with dev public IP
- [ ] 10.2 Verify Azure Load Testing resource is created successfully
- [ ] 10.3 Verify Application Insights integration is working
- [ ] 10.4 Verify Key Vault credential retrieval works in test context
- [ ] 10.5 Execute smoke-test profile manually against dev public IP and verify results
- [ ] 10.6 Execute load-test profile manually against dev public IP and verify metrics collection
- [ ] 10.7 Execute spike-test profile manually against dev public IP and verify system behavior under load

## 11. Validation and Integration

- [ ] 11.1 Validate JMeter test scripts for syntax and compatibility with Azure Load Testing
- [ ] 11.2 Verify all assertion criteria are working correctly against public IP
- [ ] 11.3 Verify test data extraction and correlation between requests
- [ ] 11.4 Validate metrics in Application Insights dashboard
- [ ] 11.5 Create Application Insights workbook/dashboard for test results visualization
- [ ] 11.6 Test cleanup procedures (artifacts, logs) after test execution

## 12. Documentation and Knowledge Transfer

- [ ] 12.1 Create deployment guide in project wiki/docs
- [ ] 12.2 Document how to run load tests against the public IP from CLI/Portal
- [ ] 12.3 Document how to interpret test results and metrics
- [ ] 12.4 Document how to modify test profiles and create new scenarios
- [ ] 12.5 Create runbook for common operational tasks (run tests, troubleshoot, analyze results)
- [ ] 12.6 Document cost considerations and quota limits

## 13. Production Deployment

- [ ] 13.1 Deploy Bicep templates to staging environment with staging public IP
- [ ] 13.2 Execute full test suite in staging against staging public IP and validate results
- [ ] 13.3 Deploy Bicep templates to production environment with production public IP
- [ ] 13.4 Configure production-specific test profiles with appropriate load levels
- [ ] 13.5 Execute production validation tests (smoke test before load test)
- [ ] 13.6 Establish baseline metrics for future regression detection

