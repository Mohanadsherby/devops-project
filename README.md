# devops-project: Helm Chart, Tekton Pipelines and ArgoCD Apps

<p align="center">
  <img src="devops-project.png" alt="devops-project">
  <br>
  <em>devops-project integrates both Helm charts, Tekton pipelines & ArgoCD to streamline deployment and CI/CD processes.
</em>
</p>

## Table of Contents

- [Overview](#overview)
  - [Table of Contents](#table-of-contents)
  - [Configuration Philosophy](#configuration-philosophy)
  - [Tekton Pipelines](#tekton-pipelines)
  - [Features](#features)
  - [Quick Start Guide](#quick-start-guide)
    - [Installation](#installation)
    - [Visiting your application](#visiting-your-application)
    - [Resources Created](#resources-created)
    - [Upgrading](#upgrading)
    - [Uninstalling](#uninstalling)
    - [Troubleshooting](#troubleshooting)
  - [Upcoming Features](#upcoming-features)
    - [External Secrets Management Support](#external-secrets-management-support)

## Configuration Philosophy

The project follows a "configure once, deploy many" philosophy, where a single values file can define the deployment configuration for multiple microservices. This approach:

- Reduces configuration duplication across services
- Ensures consistency in deployment patterns
- Simplifies maintenance and updates
- Provides a standardized way to handle service-specific customizations

Each microservice can be configured through its own configuration file, inheriting common configurations while allowing for service-specific overrides when needed.


## Tekton Pipelines

This section provides an overview of Tekton pipelines included in the devops-project project. The pipelines are configured to build and deploy various microservices using Tekton tasks and pipelines defined in the `tekton` directory.

### Prerequisites

- Kubernetes cluster
- Tekton installed on the cluster
- kubectl configured to access your cluster
- Tekton CLI (tkn) installed

### Running the Pipeline

To trigger a pipeline for a specific service, use the `run.sh` script with the appropriate service shorthand:

```bash
./run.sh <service_shorthand>
```

Service shorthands:
- `fs` - Frontend Service
- `vs` - Backend Service

Example:
```bash
./run.sh fs  # Triggers pipeline for Frontend Service
```

### Pipeline Components

The pipeline includes several tasks:
- Clone repository
- Build Docker images

## Quick Start Guide

### Installation

To install the devops-project , follow these steps:

1. Clone the repository:
   ```bash
   git clone https://github.com/Mohanadsherby/devops-project.git
   cd devops-project
   ```

2. Install necessary dependencies and tools (e.g., Helm, Tekton CLI).

3. Deploy the Helm chart:
   ```bash
   helm install frontend -n default . -f helm-chart/values/frontend-values.yaml
   ```

### Visiting your application

Once deployed, access your application via the provided service URL. Use `kubectl` to retrieve the service URL if necessary:

```bash
kubectl get svc
```

### Resources Created

The deployment creates the following resources:
- Pods
- Services
- ConfigMaps
- Secrets
- HorizontalPodAutoscaler
- Deployment
- Route
- ServiceAccount

### Uninstalling

To uninstall the deployment:

```bash
helm uninstall frontend
```

### Troubleshooting

For troubleshooting common issues, refer to the logs of the pods and Tekton tasks:

```bash
kubectl logs <pod-name>
```

## Upcoming Features

### External Secrets Management Support

Support for external secrets management is planned to enhance security and flexibility in handling sensitive information. The upcoming integrations include:

- **Sealed Secrets**: Integration with Bitnami's Sealed Secrets for encrypting secrets at rest.
- **HashiCorp Vault**: Support for dynamic secrets and centralized secret management.
- **AWS Secrets Manager**: Native integration with AWS secret management service.
- **External Secrets Operator**: Support for managing secrets across multiple providers.

These integrations will allow you to:
- Store secrets securely in production environments.
- Manage secrets separately from application configuration.
- Follow security best practices for secret management.
