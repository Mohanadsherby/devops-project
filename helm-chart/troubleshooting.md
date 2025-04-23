# Troubleshooting Guide

## Table of Contents

1. [Common Issues and Solutions](#common-issues-and-solutions)
   - [Pod Issues](#pod-issues)
     - [CrashLoopBackOff](#crashloopbackoff)
     - [Container Configuration Error](#container-configuration-error)
     - [Pods in Pending State](#pods-in-pending-state)
     - [Image Pull Errors](#image-pull-errors)
     - [Deployment Running but Pods Missing](#deployment-running-but-pods-missing)
   - [Service Issues](#service-issues)
     - [Service Not Accessible](#service-not-accessible)
     - [Port Conflicts](#port-conflicts)
   - [Configuration Issues](#configuration-issues)
     - [ConfigMap/Secret Mounting Problems](#configmapsecret-mounting-problems)
2. [Debugging Commands](#debugging-commands)
   - [Pod Debugging](#pod-debugging)
   - [Resource Checking](#resource-checking)
   - [Network Debugging](#network-debugging)
3. [Best Practices](#best-practices)
4. [Additional Resources](#additional-resources)

## Common Issues and Solutions

### Pod Issues

#### CrashLoopBackOff
Error message:
```
Status: CrashLoopBackOff
LastState: [Exit Code 1]
```
**Solution:**
1. Check pod logs: `kubectl logs <pod-name>`
2. Check previous pod logs: `kubectl logs <pod-name> --previous`
3. Check pod events: `kubectl describe pod <pod-name>`
4. Verify environment variables and configurations
5. Check if the application inside container is working properly

#### Container Configuration Error
Error message:
```
Warning  Failed     <time>  kubelet  Error: container has runAsNonRoot and image will run as root
```
**Solution:**
1. Update container security context in deployment
2. Set proper user in Dockerfile
3. Verify container configuration in deployment yaml

#### Pods in Pending State
Error message:
```
Status: Pending
Events:
  Warning  FailedScheduling  default-scheduler  0/3 nodes are available: 3 Insufficient memory
```
**Solution:**
1. Check node resources: `kubectl describe nodes`
2. Verify resource requests and limits
3. Check if nodes are cordoned
4. Ensure proper node selectors/affinity rules

#### Image Pull Errors
Error message:
```
Failed to pull image: rpc error: code = Unknown desc = Error response from daemon: pull access denied, repository does not exist or may require authentication
```
**Solution:**
1. Verify image name and tag
2. Check imagePullSecret exists: `kubectl get secret`
3. Ensure registry credentials are correct
4. Verify network connectivity to registry

#### Deployment Running but Pods Missing
**Possible causes:**
1. ReplicaSet issues
2. Resource constraints
3. Node scheduling issues

**Solution:**
1. Check deployment events: `kubectl describe deployment <name>`
2. Verify ReplicaSet status: `kubectl get rs`
3. Check pod events: `kubectl get events`
4. Review node capacity and scheduling rules

### Service Issues

#### Service Not Accessible
**Check:**
1. Service ports configuration:
```bash
kubectl get svc <service-name> -o yaml
```
2. Endpoint existence:
```bash
kubectl get endpoints <service-name>
```
3. Pod label matching:
```bash
kubectl get pods --show-labels
```

#### Port Conflicts
**Solution:**
1. Check service port mappings
2. Verify no port conflicts on nodes
3. Ensure services use unique ports
4. Check NodePort range if using NodePort services

### Configuration Issues

#### ConfigMap/Secret Mounting Problems
**Check:**
1. ConfigMap/Secret exists:
```bash
kubectl get configmap
kubectl get secret
```
2. Proper mounting in pod spec:
```yaml
volumes:
  - name: config-volume
    configMap:
      name: my-config
```
3. Volume mounts in container spec:
```yaml
volumeMounts:
  - name: config-volume
    mountPath: /etc/config
```

### Debugging Commands

#### Pod Debugging
```bash
# Get pod logs
kubectl logs <pod-name>

# Get previous pod logs
kubectl logs <pod-name> --previous

# Describe pod
kubectl describe pod <pod-name>

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/sh
```

#### Resource Checking
```bash
# Check node resources
kubectl describe nodes

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Check pod resource usage
kubectl top pods
```

#### Network Debugging
```bash
# Test service DNS
kubectl run -it --rm debug --image=busybox -- nslookup <service-name>

# Check service endpoints
kubectl get endpoints <service-name>

# Port-forward for testing
kubectl port-forward <pod-name> local-port:pod-port
```

## Best Practices

1. Always check logs first
2. Review recent changes before troubleshooting
3. Verify configurations in version control
4. Use proper resource requests/limits
5. Implement health checks
6. Maintain updated documentation
7. Use meaningful labels for resources
8. Implement proper monitoring and alerting

## Additional Resources

- Kubernetes documentation: https://kubernetes.io/docs/tasks/debug/
- kubectl cheat sheet: https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- Container runtime documentation