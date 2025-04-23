# Tekton CI/CD Pipeline Project

This repository contains Tekton pipeline configurations for building and deploying various microservices.

## Project Structure

```
.
├── tasks/              # Tekton task definitions
├── services/           # Service-specific pipeline configurations
├── secrets/           # Secret configurations
├── extra/             # Additional resources
└── run.sh             # Pipeline execution script
```

## Prerequisites

- Kubernetes cluster
- Tekton installed on the cluster
- kubectl configured to access your cluster
- Tekton CLI (tkn) installed

```
# For Windows
choco install tektoncd-cli --confirm
choco install kubernetes-cli
choco install kubernetes-helm
choco install openshift-cli

# For Mac & Linux
brew install tektoncd-cli
brew install kubernetes-cli
brew install helm
brew install openshift-cli
```

## Available Services

The pipeline supports the following services:

- Frontend Service (fs)
- backend Service (bs)

## Running the Pipeline

To trigger a pipeline for a specific service, use the `run.sh` script with the appropriate service shorthand:

```bash
./run.sh <service_shorthand>
```

Service shorthands:
- `fs` - Frontend Service
- `bs` - backend Service

Example:
```bash
./run.sh fs  # Triggers pipeline for Frontend Service
```

## Pipeline Components

The pipeline includes several tasks:
- Clone repository
- Build Maven projects
- Build Docker images
- Push artifacts
- Validate commit messages
- Build frontend applications

## Monitoring Pipeline Execution

After triggering a pipeline, you can monitor its progress using:

```bash
tkn pr logs -f <service-name>-pipeline-run-24
```

## Troubleshooting

If you encounter issues, you can:
1. Check pipeline status: `tkn pipeline list`
2. View pipeline run details: `tkn pipelinerun describe`
3. Debug specific pods using: `oc debug pod/<pod-name>`

## Adding New Services

To add a new service to the pipeline, follow these steps:

1. Choose an existing service that's similar to your new service (e.g., if adding a new frontend service, use `frontend-service` as template)

2. In the `services/` directory:
   - Create a new directory for your service: `services/your-service-name/`
   - Copy and modify the pipeline files from the template service:
     ```bash
     cp services/frontend-service/frontend-service-pipeline.yaml services/your-service-name/your-service-pipeline.yaml
     cp services/frontend-service/frontend-service-pipeline-run.yaml services/your-service-name/your-service-pipeline-run.yaml
     ```
   - Update the copied files:
     - Replace all occurrences of the template service name with your service name
     - Modify tasks and parameters as needed for your service

3. If you need custom tasks:
   - Add new task definitions in the `tasks/` directory
   - Name them appropriately (e.g., `build-your-service-task.yaml`)

4. Update `run.sh`:
   - Add a new shorthand for your service in the case statement:
     ```bash
     ys) folder="your-service" ;;  # your-service
     ```

5. Test your pipeline:
   ```bash
   ./run.sh ys  # using your new service shorthand
   ```

Remember to:
- Keep naming consistent across all files
- Test the pipeline thoroughly before committing
- Update any relevant documentation

## The Tekton Trigger
For tekton to be auto triggered on changes on any source code repo manager you'll need to install tekton crds to be able to do so

```
# Install and set up Tekton Triggers
kubectl apply --filename \
https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply --filename \
https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
```

### Note: This would work on kuberenetes without an issue but on openshift you'll need to update the userid to an id that matches the openshift user range
Afterwards you must have a listener for each service like the one in services/backend-service/tekton-listener-trigger.yaml
Then provision a route for your service webhook service like the one in services/backend-service/tekton-listener-route.yaml

```
kubectl apply -f services/backend-service/tekton-listener-trigger.yaml
kubectl apply -f services/backend-service/tekton-listener-route.yaml
```

### You can now test your new webhook listener with a post request

```
curl -k -X POST \
 https://backend-service-webhook.apps.local \
 -H 'Content-Type: application/json' \
 -d '{"branch": "main"}'
```

### Now how to deploy your microservice with helm

```
# After the pipeline finishes
cd ../helm-chart

# Pull new changes (which are the new image name and tag)
git pull

# Now make sure you're on the default project
oc project default

# Now run the following command 
helm upgrade --install backend -n default . -f values/backend-values.yaml

# Now lets check if the pod got replaced with a new one
oc get pods

# Now lets get the domain name
oc get route
```

## Notes

- The pipeline automatically applies all necessary tasks and configurations
- Each service has its own pipeline and pipeline-run configuration
- Pipeline runs are forced to ensure clean execution each time

