# .NET Aspire Setup for CraftedSpecially

This document explains the .NET Aspire integration that has been added to the CraftedSpecially project.

## Overview

.NET Aspire is a cloud-native stack for building distributed applications. It provides:
- Built-in telemetry and observability
- Service discovery and configuration
- Health checks and monitoring
- Local development orchestration

## Architecture

The Aspire setup consists of:

### 1. CraftedSpecially.AppHost
- **Purpose**: Orchestrates the entire application
- **Location**: `/CraftedSpecially.AppHost/`
- **Usage**: Run `dotnet run` to start the entire application stack

### 2. CraftedSpecially.ServiceDefaults
- **Purpose**: Provides shared configuration for all services
- **Location**: `/CraftedSpecially.ServiceDefaults/`
- **Features**:
  - OpenTelemetry configuration
  - Health checks
  - Service discovery
  - HTTP resilience

### 3. Updated WebApi Service
- **Integration**: References ServiceDefaults
- **New Endpoints**:
  - `/health` - Overall health check
  - `/alive` - Liveness probe
- **Telemetry**: Automatic metrics, traces, and logs

## Running the Application

### Option 1: Using Aspire AppHost (Recommended)
```bash
cd CraftedSpecially.AppHost
dotnet run
```

This will start the Aspire dashboard and orchestrate all services.

### Option 2: Running Services Individually
```bash
cd Services/Catalog/Interface/WebApi
dotnet run
```

## Health Checks

The application now includes built-in health checks:

- **Health Check**: `GET /health` - Returns the overall health status
- **Liveness Check**: `GET /alive` - Returns liveness status (minimal check)

## Telemetry

The application includes automatic telemetry collection:

- **Metrics**: ASP.NET Core metrics, HTTP client metrics, runtime metrics
- **Traces**: Request tracing, HTTP client tracing
- **Logs**: Structured logging with OpenTelemetry

## Development

### Prerequisites
- .NET 8.0 SDK
- .NET Aspire workload (optional for full orchestration)

### Installation
To install the .NET Aspire workload:
```bash
dotnet workload install aspire
```

### Building
```bash
dotnet build CraftedSpecially.sln
```

### Testing
```bash
dotnet test
```

## Configuration

Service configuration is handled through:
- `appsettings.json` - Application settings
- Environment variables - Runtime configuration
- Aspire configuration - Service discovery and telemetry

## Monitoring

In development, health checks are available at:
- `/health` - Full health check
- `/alive` - Liveness check

For production deployments, consider:
- Configuring proper health check endpoints
- Setting up monitoring dashboards
- Configuring alerting based on health status