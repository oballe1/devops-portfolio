# DevOps Portfolio Helm Chart

This Helm chart deploys a static portfolio website using nginx with integrated cert-manager for SSL certificates and nginx-ingress for external access.

## Prerequisites

- Kubernetes cluster (1.19+)
- Helm 3.x
- kubectl configured to access your cluster

## Dependencies

This chart includes the following dependencies:
- **nginx-ingress**: Ingress controller for external access
- **cert-manager**: Automatic SSL certificate management

## Quick Start

### 1. Add Required Helm Repositories

```bash
# Add nginx-ingress repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# Add cert-manager repository
helm repo add jetstack https://charts.jetstack.io

# Update repositories
helm repo update
```

### 2. Install Dependencies First

```bash
# Install cert-manager
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true

# Install nginx-ingress
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace
```

### 3. Deploy the Portfolio

```bash
# Install the chart
helm install devops-portfolio ./helm/devops-portfolio \
  --namespace devops-portfolio \
  --create-namespace

# Or install with custom values
helm install devops-portfolio ./helm/devops-portfolio \
  --namespace devops-portfolio \
  --create-namespace \
  --values ./helm/devops-portfolio/values-prod.yaml
```

## Configuration

### Key Values to Update

Update these values in `values.yaml` before deployment:

```yaml
# Update with your ECR repository
image:
  repository: your-account-id.dkr.ecr.us-east-1.amazonaws.com/devops-portfolio
  tag: "latest"

# Update with your domain
ingress:
  hosts:
    - host: portfolio.yourdomain.com  # Change this
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: portfolio-tls
      hosts:
        - portfolio.yourdomain.com  # Change this
```

### Environment-Specific Deployments

Create environment-specific values files:

**Development:**
```bash
helm install devops-portfolio-dev ./helm/devops-portfolio \
  --namespace devops-portfolio-dev \
  --create-namespace \
  --set environments.dev.enabled=true \
  --set image.tag=dev-latest
```

**Production:**
```bash
helm install devops-portfolio-prod ./helm/devops-portfolio \
  --namespace devops-portfolio-prod \
  --create-namespace \
  --set environments.prod.enabled=true \
  --set image.tag=prod-latest
```

## Features

### Security
- ✅ Non-root container execution
- ✅ Security contexts and pod security standards
- ✅ Network policies for traffic isolation
- ✅ Automatic SSL certificates via Let's Encrypt

### High Availability
- ✅ Horizontal Pod Autoscaler (HPA)
- ✅ Pod Disruption Budget (PDB)
- ✅ Rolling update deployment strategy
- ✅ Health checks (liveness and readiness probes)

### Observability
- ✅ Resource limits and requests
- ✅ Structured logging
- ✅ Prometheus metrics (optional)

## Upgrading

```bash
# Upgrade to new image version
helm upgrade devops-portfolio ./helm/devops-portfolio \
  --namespace devops-portfolio \
  --set image.tag=v1.2.0

# Upgrade with new values
helm upgrade devops-portfolio ./helm/devops-portfolio \
  --namespace devops-portfolio \
  --values ./helm/devops-portfolio/values-updated.yaml
```

## Uninstalling

```bash
# Uninstall the chart
helm uninstall devops-portfolio --namespace devops-portfolio

# Delete namespace
kubectl delete namespace devops-portfolio
```

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -n devops-portfolio
kubectl describe pod <pod-name> -n devops-portfolio
```

### Check Ingress
```bash
kubectl get ingress -n devops-portfolio
kubectl describe ingress devops-portfolio -n devops-portfolio
```

### Check Certificates
```bash
kubectl get certificates -n devops-portfolio
kubectl describe certificate portfolio-tls -n devops-portfolio
```

### View Logs
```bash
kubectl logs deployment/devops-portfolio -n devops-portfolio
```

## Custom nginx Configuration

The chart includes a ConfigMap for custom nginx configuration. You can modify the `configMap.data.nginx.conf` value in `values.yaml` to customize nginx behavior.

## Monitoring

To enable Prometheus monitoring, set:

```yaml
monitoring:
  enabled: true
  serviceMonitor:
    enabled: true
```

## Support

For issues and questions, please check:
- Kubernetes cluster status
- Helm chart values configuration
- Certificate manager logs
- Ingress controller logs