# OpenTelemetry Metrics Implementation for CraftedSpecially

## Overview
This implementation adds comprehensive OpenTelemetry metrics to the CraftedSpecially Catalog API to provide Service Level Indicators (SLIs) for monitoring application health and performance.

## Metrics Categories

### 1. HTTP Request Metrics (ASP.NET Core Instrumentation)
Automatically collected by the OpenTelemetry ASP.NET Core instrumentation:
- `http_request_duration` - Request processing time
- `http_requests_total` - Total number of HTTP requests  
- `http_request_status` - HTTP response status codes

### 2. Business Operation Metrics (Custom)

#### Product Registration Metrics
- **product_registration_total** (Counter)
  - Description: Total number of product registration attempts
  - Labels: `operation=registerproduct`

- **product_registration_errors_total** (Counter)  
  - Description: Total number of product registration errors
  - Labels: `operation=registerproduct`, `error_type={ExceptionType}`

- **product_registration_duration_seconds** (Histogram)
  - Description: Duration of product registration operations
  - Labels: `operation=registerproduct`, `status={success|error}`

#### Product Lookup Metrics
- **product_lookup_total** (Counter)
  - Description: Total number of product lookup operations
  - Labels: `operation=product_exists_check`

- **product_lookup_duration_seconds** (Histogram)
  - Description: Duration of product lookup operations  
  - Labels: `operation=product_exists_check`, `found={true|false}`, `status={success|error}`

## Service Level Indicators (SLIs)

### Availability SLIs
- **Success Rate**: `(total_requests - error_requests) / total_requests`
- **Error Rate**: `error_requests / total_requests`

### Performance SLIs  
- **Request Latency**: P50, P95, P99 percentiles of `http_request_duration`
- **Business Operation Latency**: P95 of `product_registration_duration_seconds`

### Throughput SLIs
- **Request Rate**: Rate of `http_requests_total`
- **Business Operation Rate**: Rate of `product_registration_total`

## Configuration

### OpenTelemetry Setup (Program.cs)
```csharp
builder.Services.AddOpenTelemetry()
    .WithMetrics(metrics =>
    {
        metrics
            .AddAspNetCoreInstrumentation()      // HTTP metrics
            .AddMeter("CraftedSpecially.Catalog"); // Custom metrics
            
        if (builder.Configuration.GetValue<bool>("OpenTelemetry:Metrics:ConsoleExporter:Enabled", true))
        {
            metrics.AddConsoleExporter();
        }
    });
```

### Configuration Settings (appsettings.json)
```json
{
  "OpenTelemetry": {
    "ServiceName": "CraftedSpecially.Catalog",
    "ServiceVersion": "1.0.0",
    "Metrics": {
      "ConsoleExporter": {
        "Enabled": true,
        "ExportIntervalMilliseconds": 10000
      }
    }
  }
}
```

## Implementation Details

### Meter Definition
All custom metrics use the same meter instance:
```csharp
private static readonly Meter _meter = new("CraftedSpecially.Catalog");
```

### Metric Instrumentation Pattern
```csharp
var stopwatch = System.Diagnostics.Stopwatch.StartNew();
try
{
    _operationCounter.Add(1, new KeyValuePair<string, object?>("operation", "operation_name"));
    
    // Perform business operation
    var result = await SomeBusinessOperation();
    
    stopwatch.Stop();
    _operationDuration.Record(stopwatch.Elapsed.TotalSeconds, 
        new KeyValuePair<string, object?>("operation", "operation_name"),
        new KeyValuePair<string, object?>("status", "success"));
        
    return result;
}
catch (Exception ex)
{
    stopwatch.Stop();
    _errorCounter.Add(1, 
        new KeyValuePair<string, object?>("operation", "operation_name"),
        new KeyValuePair<string, object?>("error_type", ex.GetType().Name));
    
    _operationDuration.Record(stopwatch.Elapsed.TotalSeconds, 
        new KeyValuePair<string, object?>("operation", "operation_name"),
        new KeyValuePair<string, object?>("status", "error"));
        
    throw;
}
```

## Production Considerations

### Exporters
For production, replace ConsoleExporter with:
- **Prometheus**: For metrics scraping
- **OTLP**: For OpenTelemetry Collector
- **Azure Monitor**: For Azure Application Insights

### Example Prometheus Configuration:
```csharp
metrics.AddPrometheusExporter();
```

### Alerting Rules Examples
```yaml
# High error rate
- alert: HighErrorRate
  expr: rate(product_registration_errors_total[5m]) / rate(product_registration_total[5m]) > 0.05
  
# High latency  
- alert: HighLatency
  expr: histogram_quantile(0.95, rate(product_registration_duration_seconds_bucket[5m])) > 1.0
```

## Benefits

1. **Proactive Monitoring**: Early detection of performance degradation
2. **SLO Compliance**: Track against defined Service Level Objectives  
3. **Capacity Planning**: Monitor trends in request volumes and processing times
4. **Debugging**: Detailed error categorization and timing information
5. **Business Insights**: Track business-level operations success rates

## Testing
The implementation has been validated with a test console application that confirms:
- Metrics are properly configured and collected
- Counter and histogram metrics record values correctly
- Labels and dimensions are applied properly
- Console exporter displays metrics in expected format