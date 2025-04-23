# OctoPilot Helm Chart

<p align="center">
  <img src="OctoPilot.png" alt="OctoPilot">
  <br>
  <em>OctoPilot: A Helm Chart for Seamless Kubernetes/OpenShift Deployments</em>
</p>


## OctoPilot Helm Chart

A flexible Helm chart designed for deploying multiple microservices on OpenShift with a unified configuration approach. This chart provides a single source of truth for managing and deploying various microservices within your ecosystem, eliminating the need for separate Helm charts for each service.

### Configuration Philosophy

The chart follows a "configure once, deploy many" philosophy, where a single values file can define the deployment configuration for multiple microservices. This approach:

- Reduces configuration duplication across services
- Ensures consistency in deployment patterns
- Simplifies maintenance and updates
- Provides a standardized way to handle service-specific customizations

Each microservice can be configured through its own values file, inheriting common configurations while allowing for service-specific overrides when needed.

## Table of Contents

- [OctoPilot Helm Chart](#octopilot-helm-chart)
  - [Table of Contents](#table-of-contents)
  - [OctoPilot Helm Chart](#octopilot-helm-chart-1)
    - [Configuration Philosophy](#configuration-philosophy)
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

## Features

- Standardized deployment configuration
- Dynamic resource naming based on the microservice name defined in the values file.
- ConfigMap & Secret management (application-specific and shared)
- OpenShift Route configuration
- Horizontal Pod Autoscaling
- Health checks and probes

## Quick Start Guide

1. Copy the base values file:

   ```bash
   cp values.yaml values/<your-microservice>-values.yaml

   # Example:
   cp values.yaml values/backend-values.yaml
   ```

2. Adjust the Configuration:

   Key configurations to modify in your new values file:

   - `nameOverride`: Set to your microservice name (without the '-service/s' prefix)
   - `replicaCount`: Adjust the number of replicas
   - `namespace`: Adjust the namespace
   - `image`: Update repository and tag for your microservice

   ```yaml
   image:
     repository: your-registry/your-microservice
     tag: "1.0.0"
   ```

   - `service`: Service Configuration:

   ```yaml
   service:
     type: ClusterIP # Service type (ClusterIP, NodePort, LoadBalancer)
     port: 80 # The service Port to expose
     targetPort: 8080 # The app container port to forward to
   ```

   - `secret`: Enable if needed and add your application secrets

   ```yaml
   secret:
     enabled: true # Enable application secrets
     data:
       API_KEY: "xyz123" # Environment variable API_KEY
       DB_PASS: "pass123" # Environment variable DB_PASS
   ```

   - `configMap`: Enable if needed and add your less sensitive configuration

   ```yaml
   configMap:
     enabled: true # Enable config map
     data:
       API_URL: "http://api" # Environment variable API_URL
       MODE: "production" # Environment variable MODE
   ```

   - `route`: Enable and configure if you need external access

   ```yaml
   route:
     enabled: true # Enable external access
     hosts:
       - host: myapp.example.com # Public hostname
     tls:
       enabled: true # Enable HTTPS
   ```

   - `autoscaling`: Enable and configure if you need autoscaling

   ```yaml
   autoscaling:
     enabled: true # Enable auto scaling
     minReplicas: 2 # Minimum pods
     maxReplicas: 5 # Maximum pods
     targetCPUUtilization: 80 # Scale when CPU hits 80%
   ```

### Installation

Install your microservice:

```bash
helm install <release-name> . -f values/<your-microservice>-values.yaml

# Example:
helm install backend . -f values/backend-values.yaml
```

### Visiting your application

Visit your microservice by running the following command:

```bash
  kubectl port-forward --namespace <namespace> svc/<microservice-name> <local-port>:<service-port>

  # Example:
  kubectl port-forward --namespace default svc/backend 8080:8080
```

### Resources Created

When you install the chart, the following Kubernetes resources are created:

All resources follow the pattern `${nameOverride}-<resource>`:

1. **Deployment**

   - Runs your microservice containers
   - Configures environment variables from secrets and configmaps
   - Handles autoscaling if enabled

2. **Service**

   - Exposes your microservice internally
   - Default type: ClusterIP
   - Configurable ports

3. **Service Account**

   - Used for pod permissions

4. **Secrets**

   - Application-specific secrets for your service
   - Access to shared secrets (like database credentials)
   - There is one additional secret that is shared across all microservices `shared-secret`

5. **ConfigMap** (if enabled)

   - Stores configuration data
   - Used for environment variables

6. **Route** (if enabled)

   - Provides external access to your service
   - Configurable hostname and TLS

7. **HorizontalPodAutoscaler** (if enabled)
   - Automatically scales your pods
   - Based on CPU utilization

### Upgrading

To upgrade an existing deployment:

```bash
helm upgrade <release-name> . -f values/<your-service>-values.yaml
```

### Uninstalling

```bash
helm uninstall <release-name>
```

### Troubleshooting

If you encounter any issues, please check the [troubleshooting guide](/troubleshooting.md).

### Upcoming Features

#### External Secrets Management Support
I'm planning to add support for various external secret management solutions to enhance security in production environments:

- **Sealed Secrets**: Integration with Bitnami's Sealed Secrets for encrypting secrets at rest
- **HashiCorp Vault**: Support for dynamic secrets and centralized secret management
- **AWS Secrets Manager**: Native integration with AWS secret management service
- **External Secrets Operator**: Support for managing secrets across multiple providers

These integrations will allow you to:
- Store secrets securely in production environments
- Manage secrets separately from application configuration
- Follow security best practices for secret management

