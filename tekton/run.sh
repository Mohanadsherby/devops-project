#!/bin/bash

set -e # what this does is exit the script if there is an error

# Check if an argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <service_short_hand>"
    exit 1
fi

# Set the service folder based on the shorthand argument
case $1 in
    fs) folder="frontend-service" ;;   # frontend-service
    bs) folder="backend-service" ;;     # backend-service
    rrf) folder="repo-radar-front" ;;     # repo-radar-front
    *) echo "Invalid service shorthand. Use 'fs', 'bs', or 'rrf'." && exit 1 ;;
esac

# Apply the pipeline and pipeline-run
echo -e "--Applying tasks--\n"
kubectl apply -f ./tasks/
echo -e "\n--Applying pipeline--\n"
kubectl apply -f ./services/$folder/$folder-pipeline.yaml
echo -e "\n--Applying pipeline-run--\n"
kubectl replace -f ./services/$folder/$folder-pipeline-run.yaml --force
echo -e "\n--Showing the logs--\n"
tkn pr logs -f $folder-pipeline-run-24

# oc debug pod/backend-service-pipeline-run-24-build-docker-image-pod -n devops
# buildah login image-registry.openshift-image-registry.svc:5000

# oc get pods --selector=tekton.dev/pipelineRun=backend-service-pipeline-run-24 -o name
# oc debug pod/backend-service-pipeline-run-24-maven-build-debs-pod
# oc debug pod/backend-service-pipeline-run-24-clone-source-code-task-pod

# List available pipelines
# tkn pipeline list

# Start a pipeline named 'build-and-deploy'
# tkn pipeline start build-and-deploy \
#   -p IMAGE=myregistry.com/myapp:v1 \
#   -w name=source,claimName=my-source-pvc \
#   --serviceaccount=pipeline-sa

# tkn pipelinerun describe

# regular expression patterns to match and delete lines containing them in vs code
# ^.*Downloaded from central.*$\n?|^.*Downloading from central.*$\n?|^.*Setting up.*$\n?|^.*Adding.*$\n?|^.*Preparing.*$\n?|^.*Unpacking.*$\n?|^.*Selecting.*$\n?|^.*Get:.*$\n?
# ^.*Downloaded from central.*$\n?
# ^.*Downloading from central.*$\n?
# ^.*Setting up.*$\n?
# ^.*Adding.*$\n?
# ^.*Preparing.*$\n?
# ^.*Unpacking.*$\n?
# ^.*Selecting.*$\n?
# ^.*Get:.*$\n?

# kubectl create secret generic github-token --from-literal=token=<your_github_token> -n devops
# https://github.com/brightzheng100/tekton-pipeline-example/tree/master
