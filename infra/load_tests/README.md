# CraftedSpecially API Load Testing Suite

This directory contains Apache JMeter load test scripts for the CraftedSpecially API deployed on Kubernetes via public IP endpoint.

## Test Files

- **api-health-check.jmx** - Health and connectivity validation
- **api-core-operations.jmx** - Core API workflow testing
- **auth-common.jmx** - Shared authentication logic and token management

## Configuration

### API Endpoint

The tests target the public IP endpoint:
- **FQDN**: craftedspecially-pip.eastus.cloudapp.azure.com
- **Protocol**: HTTPS
- **Port**: 443
- **Full URL**: https://craftedspecially-pip.eastus.cloudapp.azure.com

### Test Profiles

The load testing service supports three named test profiles:

1. **Smoke Test** (`smoke-test`)
   - Users: 1
   - Duration: 2 minutes (120 seconds)
   - Ramp-up: Immediate
   - Purpose: Quick validation of API connectivity and basic functionality

2. **Load Test** (`load-test`)
   - Users: 100 (ramped over 2 minutes)
   - Duration: 10 minutes (600 seconds) at full load
   - Total time: ~12 minutes
   - Purpose: Performance baseline and capacity validation

3. **Spike Test** (`spike-test`)
   - Users: 500 (instantaneous)
   - Duration: 5 minutes (300 seconds)
   - Purpose: Behavior under sudden high load

## Prerequisites

### For Running Tests Locally

1. **Apache JMeter** (4.0 or later)
   ```bash
   # macOS
   brew install jmeter
   
   # Or download from: https://jmeter.apache.org/download_jmeter.cgi
   ```

2. **Network Access**
   - Direct HTTPS access to craftedspecially-pip.eastus.cloudapp.azure.com:443

3. **Test Credentials**
   - Valid test user account with API permissions
   - Account must be stored securely (not in code)

### For Azure Load Testing Service

1. **Azure Load Testing Resource**
   - Deployed via Bicep module `infra/modules/continuous_validation/load_testing/`
   - Must be provisioned in the same Azure subscription

2. **Application Insights Connection**
   - Connection string configured for metrics collection
   - Instrumentation key available for test configuration

3. **Azure Key Vault** (optional)
   - For secure storage of test credentials
   - Required for production test execution

## Running Tests Locally

### Using JMeter GUI

```bash
# Open a test file
jmeter -t infra/load_tests/api-health-check.jmx

# Configure API endpoint in the GUI:
# 1. Go to Thread Group > HTTP Request Defaults
# 2. Set Server Name/IP: craftedspecially-pip.eastus.cloudapp.azure.com
# 3. Set Port: 443
# 4. Set Protocol: https
# 5. Run the test
```

### Using JMeter Command Line

```bash
# Run smoke test
jmeter -n -t infra/load_tests/api-health-check.jmx \
  -Japi.host=craftedspecially-pip.eastus.cloudapp.azure.com \
  -Japi.port=443 \
  -Japi.protocol=https \
  -l results.jtl \
  -j jmeter.log

# Generate HTML report
jmeter -g results.jtl -o report/
```

## Running Tests via Azure Load Testing

### Upload Test Files

1. **Using Azure Portal**
   - Navigate to your Azure Load Testing resource
   - Click "Create" → "Upload a JMeter script"
   - Upload the .jmx file
   - Configure test parameters

2. **Using Azure CLI**
   ```bash
   az load create --test-id crafted-specially-api \
     --load-test-resource-name CraftedSpecially-loadtest-staging \
     --resource-group CraftedSpecially \
     --display-name "CraftedSpecially API - Load Test" \
     --test-description "Core operations load test" \
     --engine-instances 1 \
     --test-file-path infra/load_tests/api-core-operations.jmx \
     --env-file-path infra/load_tests/test.env
   ```

## Test Assertions and Success Criteria

### Health Check Test
- ✅ HTTP 200 response for /health endpoint
- ✅ Response time < 500ms (p95)
- ✅ 0% error rate

### Core Operations Test
- ✅ HTTP 200/201/204 for successful operations
- ✅ HTTP 400/401/403 for expected failures
- ✅ Response time < 1000ms (p95) for interactive endpoints
- ✅ Response time < 5000ms (p95) for background operations
- ✅ Error rate < 1%

## Interpreting Results

### Key Metrics

- **Response Time (p50, p95, p99)**: Latency percentiles
  - p50: 50% of requests respond within this time
  - p95: 95% of requests respond within this time
  - p99: 99% of requests respond within this time

- **Throughput (requests/sec)**: Request volume handled by API

- **Error Rate**: Percentage of failed requests

### Performance Analysis

1. **Check response times** - Are they within acceptable ranges?
2. **Check error rate** - Should be < 1% for normal operations
3. **Check throughput** - Is API handling the target load?
4. **Check resource utilization** - Monitor CPU/memory from Application Insights

## Troubleshooting

### Connection Errors

**Symptom**: "Connection refused" or "Cannot resolve host"

**Solutions**:
- Verify API endpoint FQDN: `nslookup craftedspecially-pip.eastus.cloudapp.azure.com`
- Verify API is running: `curl -k https://craftedspecially-pip.eastus.cloudapp.azure.com/health`
- Check firewall rules allowing HTTPS traffic

### Authentication Failures

**Symptom**: "401 Unauthorized" responses

**Solutions**:
- Verify test credentials are valid
- Check token refresh logic in auth-common.jmx
- Verify test user has required permissions
- Check Key Vault credential retrieval (if using Azure)

### High Error Rates

**Symptom**: > 1% of requests fail during load test

**Solutions**:
- Reduce load (lower thread count)
- Check API logs for errors
- Verify API health check before starting load test
- Check for rate limiting or quota issues
- Review Application Insights for backend errors

### Slow Response Times

**Symptom**: Response times exceed acceptable thresholds

**Solutions**:
- Check API resource utilization (CPU, memory)
- Look for slow queries in Application Insights
- Profile the code to identify bottlenecks
- Consider scaling the API deployment (more replicas)

## Customizing Tests

### Adding New Test Scenarios

1. Copy an existing test file (e.g., `api-health-check.jmx`)
2. Open in JMeter GUI
3. Add new HTTP Request samplers for your endpoints
4. Configure assertions and response time limits
5. Add think time between requests for realistic behavior
6. Save and upload to Azure Load Testing

### Modifying Load Profiles

Edit the Bicep parameters in `infra/params.bicepparam`:

```bicep
// In params.bicepparam - increase load test intensity
param loadTestThreads = 200        // Up from 100
param loadTestDurationSeconds = 900 // Up from 600 (15 minutes)
```

### Adding Data Parameterization

Create a CSV file with test data:

```csv
userId,userEmail
user1,user1@test.com
user2,user2@test.com
```

Reference in JMeter:
1. Add "CSV Data Set Config" element
2. Point to your CSV file
3. Reference variables in requests (e.g., `${userId}`)

## Monitoring During Test Execution

### Azure Load Testing Dashboard

- Real-time request rates and response times
- Client-side metrics (errors, throughput)
- Server-side metrics via Application Insights integration

### Application Insights

Access logs and metrics:

```kusto
customMetrics
| where name in ("load_test_request_time", "load_test_error_rate")
| summarize avg(value) by tostring(customDimensions.test_profile)
```

## Cost Considerations

### Azure Load Testing Pricing

- Charged per Virtual User Hour (VUH)
- Example: 100 users × 12 minutes ≈ 0.2 VUH
- See [Azure Load Testing Pricing](https://azure.microsoft.com/en-us/pricing/details/load-testing/) for current rates

### Cost Optimization Tips

- Use smoke tests for validation before full load tests
- Schedule tests during off-hours if possible
- Use minimum engine instances required
- Clean up test artifacts after completion

## Documentation and References

- [Apache JMeter Documentation](https://jmeter.apache.org/usermanual/index.html)
- [Azure Load Testing Documentation](https://learn.microsoft.com/en-us/azure/load-testing/)
- [JMeter Best Practices](https://jmeter.apache.org/usermanual/best-practices.html)

## Support and Questions

For issues or questions:
1. Check the Troubleshooting section above
2. Review test logs in JMeter: `jmeter.log`
3. Check Application Insights for backend errors
4. Contact the CraftedSpecially development team
