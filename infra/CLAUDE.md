# Infrastructure

THe infrastructure is split up into modules, each module a layer of the application infrastructure.
The modules are:

- Technical infrastructure: Contains the infrastructure for networking, Storage and compute resources.
- Runtime_infrastructure: Contains observability and monitoring infrastructure, orchestration and (web) app hosting.
- Application_infrastructure: Contains the infrastructure for the application itself, such as databases, message queues, and other services that the application depends on.
- Management_governance: Contains the infrastructure related to Governance services, security, reliability and compliance, identity and access management, and secret management.

The infrastructure must be as cloud agnostic as possible. I want to include CNCF certified tools and services, and open source tools where possible.
I want to avoid vendor lock-in and ensure that the infrastructure can be easily migrated to different cloud providers or on-premises environments if needed.

Azure infrastructure can be written in Bicep.