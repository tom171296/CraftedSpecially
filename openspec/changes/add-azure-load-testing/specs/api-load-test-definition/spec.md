## ADDED Requirements

### Requirement: JMeter Test Script Format
The system SHALL define load test scenarios using Apache JMeter format (.jmx files) that are compatible with Azure Load Testing.

#### Scenario: Create valid JMeter test script
- **WHEN** a new load test scenario is defined
- **THEN** it is created as a .jmx file following Apache JMeter XML schema and is compatible with Azure Load Testing

#### Scenario: Import existing JMeter script
- **WHEN** an existing JMeter test script exists in the repository
- **THEN** it can be uploaded to Azure Load Testing for execution without modification

#### Scenario: Test script validation
- **WHEN** a test script is created or modified
- **THEN** it can be validated by Azure Load Testing before execution to catch syntax errors

### Requirement: Public IP Endpoint Targeting
The system SHALL define load test scenarios that target the Kubernetes API service via its public IP address.

#### Scenario: Target public IP endpoint
- **WHEN** a load test is executed
- **THEN** it uses the configured public IP address and port to reach the API service

#### Scenario: Test via public IP protocol
- **WHEN** the API service is exposed via HTTP or HTTPS on the public IP
- **THEN** test requests use the correct protocol configured for that endpoint

#### Scenario: DNS or IP-based targeting
- **WHEN** the API is accessible via both DNS name and public IP
- **THEN** load tests use the public IP address directly to avoid DNS resolution variability

#### Scenario: Port-specific access
- **WHEN** the public IP service uses a non-standard port (not 80/443)
- **THEN** test requests include the correct port in the target URL

### Requirement: API Endpoint Coverage
The system SHALL define test scenarios that cover all major API endpoints and business workflows exposed via the public IP.

#### Scenario: Health check endpoint
- **WHEN** the load test suite runs against the public IP
- **THEN** it includes a test for the API health check endpoint (/health or /ping)

#### Scenario: Authentication workflow
- **WHEN** protected API endpoints are tested via public IP
- **THEN** the test suite includes authentication steps (login, token acquisition) before calling protected endpoints

#### Scenario: Core business operations
- **WHEN** the load test suite is executed against the public IP
- **THEN** it includes requests that exercise core API operations relevant to the CraftedSpecially domain

#### Scenario: Realistic user behavior simulation
- **WHEN** the load test runs with multiple simulated users against public IP
- **THEN** request patterns include think time (delays between requests) to simulate realistic user behavior

### Requirement: Load Profile Definition
The system SHALL support multiple load profiles with different user loads and ramp-up patterns.

#### Scenario: Smoke test profile execution
- **WHEN** the smoke-test profile is selected
- **THEN** the test runs with 1 concurrent user for 2 minutes to validate basic connectivity

#### Scenario: Standard load test profile execution
- **WHEN** the load-test profile is selected
- **THEN** the test ramps up to 100 concurrent users over 2 minutes, sustains for 10 minutes, then ramps down

#### Scenario: Spike test profile execution
- **WHEN** the spike-test profile is selected
- **THEN** the test instantly increases to 500 concurrent users, maintains for 5 minutes, then stops

#### Scenario: Custom load profile
- **WHEN** a user defines custom user count and duration parameters
- **THEN** the test executes with the specified load profile

### Requirement: Authentication and Authorization
The system SHALL handle API authentication in load tests securely without embedding credentials in test scripts.

#### Scenario: Secure credential management
- **WHEN** a load test requires authentication credentials
- **THEN** credentials are retrieved from Azure Key Vault at test runtime, not stored in the JMeter script or repository

#### Scenario: Token refresh during long tests
- **WHEN** a load test runs longer than token expiration time
- **THEN** the JMeter script includes logic to refresh/re-acquire authentication tokens

#### Scenario: Service principal authentication
- **WHEN** tests run in automated scenarios
- **THEN** they authenticate using service principal credentials (client ID/secret) managed in Key Vault

#### Scenario: User account authentication
- **WHEN** tests run in manual/exploratory scenarios
- **THEN** they can authenticate using a dedicated test user account with appropriate API permissions

### Requirement: Test Assertions and Success Criteria
The system SHALL define assertions to validate API responses and determine test success/failure.

#### Scenario: HTTP status code validation
- **WHEN** an API request completes
- **THEN** the test asserts that the response status code is in the 2xx range for successful operations

#### Scenario: Response time threshold
- **WHEN** an API request completes
- **THEN** the test asserts that response time is within acceptable limits (p95 < 1000ms for interactive endpoints)

#### Scenario: Response content validation
- **WHEN** an API request returns data
- **THEN** the test can validate that response content matches expected structure or contains expected values

#### Scenario: Error handling validation
- **WHEN** the API encounters an error condition
- **THEN** the test validates that error responses are properly formatted with meaningful error messages

### Requirement: Data Extraction and Correlation
The system SHALL support extracting values from API responses and using them in subsequent requests.

#### Scenario: Extract authentication token
- **WHEN** a login endpoint returns an authentication token
- **THEN** the token is extracted and automatically included in Authorization headers for subsequent requests

#### Scenario: Extract resource ID
- **WHEN** a create endpoint returns a newly created resource ID
- **THEN** the ID is extracted and used in subsequent requests to fetch, update, or delete that resource

#### Scenario: Parameterized requests
- **WHEN** test execution provides parameterized data (e.g., from CSV)
- **THEN** JMeter scripts use this data to create realistic variation across requests

### Requirement: Test Script Organization and Storage
The system SHALL organize test scripts in a discoverable and maintainable structure.

#### Scenario: Test script location
- **WHEN** load test scripts are created
- **THEN** they are stored in `infra/load_tests/` directory

#### Scenario: Test naming convention
- **WHEN** test scripts are created
- **THEN** they follow a naming convention: `<api-domain>-<scenario>.jmx` (e.g., `users-api-create-user.jmx`)

#### Scenario: Test documentation
- **WHEN** a test script is created
- **THEN** it includes a README.md in its directory explaining the test scenario, prerequisites, and expected behavior

#### Scenario: Test data files
- **WHEN** tests require parameterized data
- **THEN** data files (CSV, JSON) are stored alongside the JMeter scripts in version control

### Requirement: Monitoring and Logging During Test Execution
The system SHALL capture detailed metrics and logs during test execution for analysis and troubleshooting.

#### Scenario: Request/response logging
- **WHEN** a load test runs in debug mode
- **THEN** request and response details are logged for troubleshooting (with appropriate sampling to avoid excessive data)

#### Scenario: Performance metrics collection
- **WHEN** a test executes
- **THEN** detailed timing metrics (connect time, first byte, response time) are collected for each request

#### Scenario: Error logging
- **WHEN** a request fails
- **THEN** error details (status code, error message, response body) are logged for root cause analysis

#### Scenario: Test metrics export
- **WHEN** a test completes
- **THEN** results can be exported in standard formats (CSV, JSON) for external analysis or trending

