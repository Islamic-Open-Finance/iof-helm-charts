# Islamic Open Finance Platform - Helm Chart

This Helm chart deploys the complete Islamic Open Finance platform to Kubernetes.

## Prerequisites

- Kubernetes 1.24+
- Helm 3.14+
- PostgreSQL 16+ (external RDS or internal)
- Redis 7+ (external ElastiCache or internal)
- Meilisearch instance
- TLS certificates (for production)

## Components

This chart deploys the following components:

### Core Services

- **rail-api**: Main API service with all 18+ rails
- **analytics-api**: Analytics and reporting service
- **ledger-service**: TigerBeetle ledger integration service

### Frontend Applications

- **admin-portal**: Administrative dashboard
- **customer-dashboard**: Customer-facing dashboard
- **api-explorer**: Interactive API documentation

### Infrastructure Services

- **tigerbeetle**: High-performance distributed ledger (1M+ TPS)
- **cerbos**: Authorization policy engine
- **obp-mock**: Mock Open Banking Platform (dev/test only)

## Installation

### Quick Start (Development)

```bash
# Install with default values
helm install iof ./infra/helm/charts/iof \
  --namespace iof-dev \
  --create-namespace
```

### Production Deployment

```bash
# Create namespace
kubectl create namespace iof-production

# Create secrets
kubectl create secret generic iof-db-credentials \
  --namespace=iof-production \
  --from-literal=username=iof_user \
  --from-literal=password=<your-password>

kubectl create secret generic meilisearch-master-key \
  --namespace=iof-production \
  --from-literal=key=<your-master-key>

# Install chart
helm install iof ./infra/helm/charts/iof \
  --namespace iof-production \
  --values ./infra/helm/values-production.yaml \
  --set global.imageTag=v1.0.0 \
  --set postgresql.external.host=<rds-endpoint> \
  --set redis.external.host=<elasticache-endpoint> \
  --set meilisearch.externalUrl=https://search.yourdomain.com \
  --set railApi.ingress.hosts[0].host=api.yourdomain.com \
  --set adminPortal.ingress.hosts[0].host=admin.yourdomain.com
```

### Sandbox Deployment

```bash
helm install iof ./infra/helm/charts/iof \
  --namespace iof-sandbox \
  --values ./infra/helm/values-sandbox.yaml \
  --set global.imageTag=sha-${GITHUB_SHA}
```

## Configuration

### Global Configuration

| Parameter                  | Description                | Default                |
| -------------------------- | -------------------------- | ---------------------- |
| `global.imageRegistry`     | Container registry         | `ghcr.io`              |
| `global.imageOrganization` | Organization name          | `islamic-open-finance` |
| `global.imageTag`          | Image tag for all services | `latest`               |
| `global.imagePullPolicy`   | Image pull policy          | `IfNotPresent`         |
| `global.replicaCount`      | Default replica count      | `2`                    |

### Rail API Configuration

| Parameter                         | Description                | Default      |
| --------------------------------- | -------------------------- | ------------ |
| `railApi.enabled`                 | Enable rail-api deployment | `true`       |
| `railApi.replicaCount`            | Number of replicas         | `3`          |
| `railApi.autoscaling.enabled`     | Enable HPA                 | `true`       |
| `railApi.autoscaling.minReplicas` | Min replicas               | `3`          |
| `railApi.autoscaling.maxReplicas` | Max replicas               | `10`         |
| `railApi.ingress.enabled`         | Enable ingress             | `true`       |
| `railApi.env.NODE_ENV`            | Node environment           | `production` |

### Database Configuration

| Parameter                      | Description             | Default          |
| ------------------------------ | ----------------------- | ---------------- |
| `postgresql.external.enabled`  | Use external PostgreSQL | `true`           |
| `postgresql.external.host`     | PostgreSQL host         | `""`             |
| `postgresql.external.port`     | PostgreSQL port         | `5432`           |
| `postgresql.external.database` | Database name           | `iof_production` |
| `postgresql.external.username` | Database username       | `iof_user`       |

### TigerBeetle Configuration

| Parameter                      | Description               | Default |
| ------------------------------ | ------------------------- | ------- |
| `tigerbeetle.enabled`          | Enable TigerBeetle ledger | `true`  |
| `tigerbeetle.cluster.id`       | Cluster ID                | `0`     |
| `tigerbeetle.server.cacheGrid` | Grid cache size           | `2GB`   |
| `tigerbeetle.persistence.size` | Storage size              | `100Gi` |

## Upgrading

```bash
helm upgrade iof ./infra/helm/charts/iof \
  --namespace iof-production \
  --values ./infra/helm/values-production.yaml \
  --set global.imageTag=v1.1.0
```

## Uninstallation

```bash
helm uninstall iof --namespace iof-production
```

## Monitoring

The chart supports Prometheus monitoring via ServiceMonitor resources:

```bash
helm install iof ./infra/helm/charts/iof \
  --set serviceMonitor.enabled=true
```

## Troubleshooting

### Check pod status

```bash
kubectl get pods -n iof-production
```

### View logs

```bash
kubectl logs -f deployment/iof-rail-api -n iof-production
```

### Check ingress

```bash
kubectl get ingress -n iof-production
```

### Database migrations

```bash
kubectl run migrations \
  --namespace=iof-production \
  --image=ghcr.io/islamic-open-finance/rail-api:v1.0.0 \
  --restart=Never \
  --rm \
  -it \
  -- pnpm db:migrate
```

## Support

For issues and questions:

- GitHub: https://github.com/Islamic-Open-Finance/app/issues
- Email: platform@islamicopenfinance.com
- Documentation: https://docs.islamicopenfinance.com

## License

Proprietary - Islamic Open Finance Platform
