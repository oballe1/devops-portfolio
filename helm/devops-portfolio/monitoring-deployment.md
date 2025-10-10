# Prometheus Stack Deployment Guide

This guide explains how to deploy the complete monitoring stack with your DevOps portfolio.

## Prerequisites

- Kubernetes cluster with sufficient resources
- Helm 3.x installed
- kubectl configured
- Storage class available (e.g., gp2 for AWS EKS)

## Deployment Steps

### 1. Add Required Helm Repositories

```bash
# Add Prometheus community repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Add other required repositories
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io

# Update repositories
helm repo update
```

### 2. Update Dependencies

```bash
# Navigate to the chart directory
cd helm/devops-portfolio

# Update chart dependencies
helm dependency update
```

### 3. Deploy the Complete Stack

```bash
# Deploy everything including Prometheus stack
helm install devops-portfolio . \
  --namespace devops-portfolio \
  --create-namespace \
  --set prometheus-stack.enabled=true \
  --set cert-manager.enabled=true \
  --set nginx-ingress.enabled=true
```

### 4. Verify Deployment

```bash
# Check all pods are running
kubectl get pods -n devops-portfolio

# Check services
kubectl get svc -n devops-portfolio

# Check ingress
kubectl get ingress -n devops-portfolio
```

## Access Monitoring Tools

### Grafana Dashboard
- **URL**: https://grafana.lovethoballe.com (update in values.yaml)
- **Username**: admin
- **Password**: admin123 (change in production)

### Prometheus
- **URL**: Accessible via port-forward or configure ingress
```bash
kubectl port-forward -n devops-portfolio svc/devops-portfolio-kube-prometheus-stack-prometheus 9090:9090
```
- **Access**: http://localhost:9090

### AlertManager
- **URL**: https://alertmanager.lovethoballe.com (update in values.yaml)
- **Username**: admin
- **Password**: admin123

## Monitoring Features Included

### 📊 **Grafana Dashboards**
- Kubernetes Cluster Overview (ID: 7249)
- Kubernetes Pods (ID: 6417)
- NGINX Ingress Controller (ID: 9614)
- Custom Portfolio Dashboard

### 🔍 **Prometheus Metrics**
- Application uptime and health
- HTTP request metrics
- Resource usage (CPU, Memory)
- Kubernetes cluster metrics
- NGINX ingress metrics

### 🚨 **AlertManager**
- High CPU usage alerts
- Memory usage alerts
- Pod restart alerts
- Application downtime alerts

### 📈 **ServiceMonitor**
- Automatic service discovery
- Portfolio application metrics collection
- Custom metrics endpoint monitoring

## Configuration Details

### Resource Requirements

**Prometheus:**
- Memory: 2-4Gi
- CPU: 1-2 cores
- Storage: 50Gi (30 days retention)

**Grafana:**
- Memory: 256-512Mi
- CPU: 100-200m
- Storage: 10Gi

**AlertManager:**
- Memory: 128-256Mi
- CPU: 50-100m
- Storage: 10Gi

### Storage Configuration

The stack uses persistent volumes for:
- Prometheus data retention
- Grafana dashboards and settings
- AlertManager configuration

Update storage class in values.yaml:
```yaml
prometheus-stack:
  prometheus:
    prometheusSpec:
      storageSpec:
        volumeClaimTemplate:
          spec:
            storageClassName: your-storage-class  # Change this
```

## Customization

### Add Custom Dashboards

1. Place JSON dashboard files in `dashboards/` directory
2. Update values.yaml:
```yaml
prometheus-stack:
  grafana:
    dashboards:
      default:
        custom-dashboard:
          file: dashboards/custom-dashboard.json
```

### Configure Alerts

Create custom PrometheusRule resources:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: portfolio-alerts
spec:
  groups:
  - name: portfolio.rules
    rules:
    - alert: PortfolioDown
      expr: up{job="devops-portfolio"} == 0
      for: 5m
      annotations:
        summary: "Portfolio application is down"
```

## Troubleshooting

### Common Issues

1. **Storage Issues**: Ensure storage class exists and has sufficient space
2. **Resource Limits**: Check if cluster has enough CPU/Memory
3. **Ingress Issues**: Verify ingress controller is running
4. **SSL Certificates**: Check cert-manager pods and certificate status

### Debug Commands

```bash
# Check Prometheus targets
kubectl port-forward -n devops-portfolio svc/devops-portfolio-kube-prometheus-stack-prometheus 9090:9090

# Check ServiceMonitor
kubectl get servicemonitor -n devops-portfolio

# Check certificate status
kubectl get certificates -n devops-portfolio

# View Grafana logs
kubectl logs -n devops-portfolio deployment/devops-portfolio-grafana
```

## Environment-Specific Configuration

### Development
```bash
helm install devops-portfolio-dev . \
  --namespace devops-portfolio-dev \
  --create-namespace \
  --set prometheus-stack.enabled=false  # Disable for dev
```

### Production
```bash
helm install devops-portfolio-prod . \
  --namespace devops-portfolio-prod \
  --create-namespace \
  --set prometheus-stack.grafana.adminPassword="secure-password" \
  --set prometheus-stack.prometheus.prometheusSpec.retention=90d
```

## Security Considerations

1. **Change default passwords** in production
2. **Configure RBAC** for Grafana users
3. **Enable authentication** for Prometheus/AlertManager
4. **Use secrets** for sensitive configuration
5. **Network policies** to restrict access

## Monitoring Best Practices

1. **Set up proper alerting rules**
2. **Create runbooks for common issues**
3. **Regular backup of Grafana dashboards**
4. **Monitor resource usage trends**
5. **Set up log aggregation alongside metrics**