# OpenTelemetry Collector Integration Plan

## 1. Overview
This document outlines the architectural plan and technical steps for integrating the **OpenTelemetry (OTel) Collector** (`otel/opentelemetry-collector:nightly`) into the **CraftedSpecially** .NET Aspire solution (`CraftedSpecially.AppHost`).

The OTel Collector operates as a centralized gateway that ingests telemetry (traces, metrics, logs) from solution services, applies **adaptive tail sampling** and filtering policies, and exports telemetry to designated destinations:
- **.NET Aspire Dashboard**: Real-time local debugging and observability.
- **Azure Monitor / Application Insights**: Cloud-based central monitoring and analytics.
- **Debug / Console**: Local diagnostic logging.

---

## 2. Architecture Diagram

```
+-----------------------------------------------------------+
|                  CraftedSpecially.Api                     |
|           (and future microservices/modules)              |
+-----------------------------------------------------------+
                             |
                             | OTLP (gRPC :4317 / HTTP :4318)
                             v
+-----------------------------------------------------------+
|          OpenTelemetry Collector Contrib (Container)       |
|                                                           |
|  [Receivers]                                              |
|    - OTLP (gRPC: 0.0.0.0:4317, HTTP: 0.0.0.0:4318)       |
|                                                           |
|  [Processors]                                             |
|    - memory_limiter (protection against OOM)              |
|    - tail_sampling (adaptive multi-policy sampling)       |
|    - batch (optimized transport buffering)                |
|    - resource (service metadata enrichment)               |
|                                                           |
|  [Exporters]                                              |
|    - otlp/aspire (Aspire Dashboard OTLP endpoint)         |
|    - azuremonitor (Azure Application Insights ingestion)  |
|    - debug (standard output)                              |
+-----------------------------------------------------------+
           |                                  |
           v                                  v
+-----------------------+          +------------------------+
| .NET Aspire Dashboard |          | Azure Monitor / AppIns |
+-----------------------+          +------------------------+
```

---

## 3. Key Components & Implementation Steps

### 3.1. OpenTelemetry Collector Configuration (`otel-collector-config.yaml`)
Create `src/CraftedSpecially.AppHost/otel-collector-config.yaml` with the following configuration:

1. **Receivers**:
   - `otlp`: gRPC on `0.0.0.0:4317`, HTTP on `0.0.0.0:4318`.
2. **Processors**:
   - `memory_limiter`: Set memory limits and check intervals.
   - `tail_sampling` (Adaptive / Multi-Policy):
     - **Error Policy**: 100% sampling for traces containing spans with error status or exceptions.
     - **Latency Policy**: 100% sampling for traces exceeding latency thresholds (>500ms).
     - **Health-Check Policy**: Filter out or reduce high-frequency `/health` and `/alive` ping noise.
     - **Probabilistic / Rate-Limiting Policy**: Adaptive sampling rate (e.g., 10%) for normal/healthy traces with a rate limit safeguard.
   - `batch`: Timeout and batch size settings.
3. **Exporters**:
   - `otlp/aspire`: Forwarding to Aspire Dashboard OTLP endpoint.
   - `azuremonitor`: Ingestion via `APPLICATIONINSIGHTS_CONNECTION_STRING`.
   - `debug`: Standard console output.
4. **Extensions**:
   - `health_check` on port `13133`.
   - `zpages` diagnostic pages on port `55679`.
5. **Service Pipelines**:
   - Traces pipeline: `receivers: [otlp] -> processors: [memory_limiter, tail_sampling, batch] -> exporters: [otlp/aspire, azuremonitor, debug]`
   - Metrics pipeline: `receivers: [otlp] -> processors: [memory_limiter, batch] -> exporters: [otlp/aspire, azuremonitor, debug]`
   - Logs pipeline: `receivers: [otlp] -> processors: [memory_limiter, batch] -> exporters: [otlp/aspire, azuremonitor, debug]`

---

### 3.2. Aspire AppHost Integration (`AppHost.cs`)
In `src/CraftedSpecially.AppHost/AppHost.cs`:
- Register container resource `builder.AddContainer("otel-collector", "otel/opentelemetry-collector:nightly")`.
- Bind `otel-collector-config.yaml` to `/etc/otelcol-contrib/config.yaml`.
- Expose endpoints for gRPC (`4317`), HTTP (`4318`), Health (`13133`), Metrics (`8888`), and zpages (`55679`).
- Pass environment variables (`APPLICATIONINSIGHTS_CONNECTION_STRING`, `DOTNET_DASHBOARD_OTLP_ENDPOINT_URL`).
- Wire services (`CraftedSpecially.Api`) with reference to `otel-collector` and configure `OTEL_EXPORTER_OTLP_ENDPOINT`.

---

### 3.3. ServiceDefaults Refinements (`Extensions.cs`)
In `src/CraftedSpecially.ServiceDefaults/Extensions.cs`:
- Ensure client services export telemetry over standard OTLP to the collector endpoint.
- Avoid duplicate ingestion by ensuring direct Azure Monitor export in client services is bypassed when routing through the collector gateway.

---

### 3.4. Verification & Validation
- Run `dotnet build` to ensure all projects compile cleanly.
- Verify container startup and endpoint bindings in Aspire AppHost.
- Validate trace sampling behavior with simulated normal requests, slow requests, and error scenarios.
