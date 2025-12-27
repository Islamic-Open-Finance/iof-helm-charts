# Islamic Open Finance Platform - Helm Chart

Umbrella chart for deploying the complete Islamic Open Finance platform.

## Deployment Modes

### Mode A: Bundled Deployment (Recommended for Most Users)

Deploy all infrastructure and selectively enable rails:

```bash
helm install iof-platform ./iof-platform \
  --set global.tenant.id=tenant_123 \
  --set global.tenant.name="My Bank" \
  --set rails.contracts.enabled=true \
  --set rails.kyc.enabled=true \
  --set rails.compliance.enabled=true
```

### Mode B: Per-Rail Deployment (Advanced)

Deploy individual rail charts separately:

```bash
# Deploy core infrastructure first
helm install iof-core ./rails/core

# Deploy individual rails
helm install iof-contracts ./rails/contracts \
  --set enabled=true

helm install iof-clearing ./rails/clearing \
  --set enabled=true
```

## SKU-Based Configuration

Use SKU profiles to auto-configure rails:

```bash
# Banking Core SKU
helm install iof-platform ./iof-platform \
  --values values-sku-banking-core.yaml

# National Rail SKU
helm install iof-platform ./iof-platform \
  --values values-sku-national-rail.yaml

# Funds Pro SKU
helm install iof-platform ./iof-platform \
  --values values-sku-funds-pro.yaml
```

## Configuration

### Required Values

```yaml
global:
  tenant:
    id: "tenant_123" # Tenant identifier
    name: "My Bank" # Tenant display name
  deploymentMode: hosted # hosted | byoc | on-premise
  environment: sandbox # sandbox | uat | production | dr
```

### Rail Selection

Enable specific rails based on your SKU:

```yaml
rails:
  contracts:
    enabled: true
  kyc:
    enabled: true
  compliance:
    enabled: true
  clearing:
    enabled: false # Not included in SKU
```

### Infrastructure

Configure shared infrastructure:

```yaml
global:
  postgres:
    host: my-postgres.example.com
    port: 5432
    database: iof_prod

  clickhouse:
    host: my-clickhouse.example.com
    port: 9000

  redis:
    host: my-redis.example.com
    port: 6379
```

## Examples

### Sandbox Deployment

```bash
helm install iof-sandbox ./iof-platform \
  --set global.environment=sandbox \
  --set global.tenant.id=sandbox_001 \
  --values values-sku-sandbox-free.yaml
```

### Production Banking Deployment

```bash
helm install iof-production ./iof-platform \
  --set global.environment=production \
  --set global.tenant.id=bank_prod \
  --set global.deploymentMode=byoc \
  --values values-sku-banking-core.yaml \
  --values values-gcc-regulatory-pack.yaml
```

### Multi-Region Deployment

```bash
# Primary region (UAE)
helm install iof-uae ./iof-platform \
  --set global.region=uae-dubai-1 \
  --values values.yaml

# DR region (Saudi Arabia)
helm install iof-sau ./iof-platform \
  --set global.region=sau-riyadh-1 \
  --set global.environment=dr \
  --values values.yaml
```

## Upgrades

### Upgrading Rails

Individual rails can be upgraded independently:

```bash
# Upgrade specific rail
helm upgrade iof-contracts ./rails/contracts \
  --set image.tag=1.1.0

# Upgrade entire platform
helm upgrade iof-platform ./iof-platform \
  --set global.imageTag=1.1.0
```

### Zero-Downtime Upgrades

```bash
helm upgrade iof-platform ./iof-platform \
  --set autoscaling.enabled=true \
  --set updateStrategy.type=RollingUpdate \
  --set updateStrategy.maxSurge=1 \
  --set updateStrategy.maxUnavailable=0
```

## Uninstall

```bash
# Uninstall platform (preserves PVCs)
helm uninstall iof-platform

# Complete cleanup (including data)
helm uninstall iof-platform
kubectl delete pvc -l app.kubernetes.io/instance=iof-platform
```

## Architecture

```
iof-platform (umbrella chart)
├── iof-core (infrastructure)
│   ├── PostgreSQL
│   ├── ClickHouse
│   ├── Redis
│   └── Meilisearch
├── iof-contracts (domain rail)
├── iof-kyc (domain rail)
├── iof-compliance (domain rail)
├── iof-clearing (domain rail)
├── iof-metadata (horizontal rail)
├── iof-search (horizontal rail)
└── iof-events (horizontal rail)
```

## Support

- Documentation: https://docs.islamicopenfinance.org
- Helm Repository: https://charts.islamicopenfinance.org
- Issues: https://github.com/islamic-open-finance/platform/issues
