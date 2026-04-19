# IOF Helm Charts

Kubernetes Helm charts for deploying the Islamic Open Finance (IOF) Platform.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Helm](https://img.shields.io/badge/Helm-3.0+-blue.svg)](https://helm.sh/)

## What you're deploying

A banking-grade Shariah-native platform: **109 rails across 19 categories** (142+ endpoints) composed from **10 native domain engines** over a single double-entry ledger. Two of those engines are the platform's defensible moats — the economic reason a tier-1 balance sheet rents IOF instead of building in-house:

- **Settlement Engine** (`services/settlement-service`) — 24×7×365 DvP/FOP/RVP/DFP finality for Murabaha, Ijarah, Salam, Sukuk. AAOIFI SS-1/8/10/17/21/30 enforced at the state machine; CSDR Art. 7 penalties priced pre-confirm; ribawi-pair netting. Reclaims 60–140 bps per corridor.
- **Evidence Engine** (`services/evidence-service`) — signed, tamper-evident compliance pack on every trade. 47/54 controls across SOC 2, ISO 27001, AAOIFI, GDPR, PSD2, IFSB, ISO 20022. SHA-256 Merkle + HMAC, one-call verification. Reclaims 30–55 bps on audit + re-papering.

Combined: **100–195 bps** reclaimed per corridor. Layers over Temenos, Finastra, Mambu or Open Banking Protocol — no core replacement.

## Charts

| Chart | Description |
|-------|-------------|
| `iof` | Main IOF platform chart |
| `iof-platform` | Full platform with all components |
| `tigerbeetle` | TigerBeetle ledger database |

## Quick Start

```bash
# Add the IOF Helm repository
helm repo add iof https://charts.islamicopenfinance.com
helm repo update

# Install the IOF platform
helm install iof iof/iof-platform -f values.yaml
```

## Installation

### From Source

```bash
# Clone repository
git clone https://github.com/Islamic-Open-Finance/iof-helm-charts.git
cd iof-helm-charts

# Install main chart
helm install iof ./charts/iof -f values-sandbox.yaml
```

### From Repository

```bash
helm repo add iof https://charts.islamicopenfinance.com
helm install iof iof/iof-platform
```

## Charts Overview

### iof (Main Chart)

Core IOF Rail API and services:

```bash
helm install iof ./charts/iof \
  --set railApi.replicas=3 \
  --set railApi.resources.requests.memory=512Mi
```

### iof-platform

Full platform deployment including all dependencies:

```bash
helm install iof ./iof-platform \
  --values values-sandbox.yaml
```

### tigerbeetle

TigerBeetle ledger database:

```bash
helm install tigerbeetle ./tigerbeetle \
  --set replicas=3 \
  --set persistence.size=100Gi
```

## Configuration

### Common Values

```yaml
# values.yaml
global:
  environment: sandbox
  domain: islamicopenfinance.com

railApi:
  replicas: 3
  image:
    repository: ghcr.io/islamic-open-finance/rail-api
    tag: latest
  resources:
    requests:
      memory: 512Mi
      cpu: 250m
    limits:
      memory: 1Gi
      cpu: 1000m

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: api.islamicopenfinance.com
      paths:
        - path: /
          pathType: Prefix
```

### SKU-Based Configurations

Pre-configured values for different deployment tiers:

```bash
# Banking Core SKU
helm install iof ./iof-platform -f values-sku-banking-core.yaml

# National Rail SKU
helm install iof ./iof-platform -f values-sku-national-rail.yaml
```

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                    │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  Rail API   │  │  Rail API   │  │  Rail API   │     │
│  │  (Pod 1)    │  │  (Pod 2)    │  │  (Pod 3)    │     │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘     │
│         └────────────────┼────────────────┘             │
│                          │                              │
│  ┌───────────────────────▼───────────────────────────┐ │
│  │                   Service                          │ │
│  └───────────────────────┬───────────────────────────┘ │
│                          │                              │
│  ┌───────────────────────▼───────────────────────────┐ │
│  │                   Ingress                          │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ PostgreSQL  │  │ TigerBeetle │  │ ClickHouse  │     │
│  │ (StatefulSet)│ │ (StatefulSet)│ │ (StatefulSet)│    │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
```

## Requirements

- Kubernetes 1.25+
- Helm 3.0+
- PV provisioner support (for StatefulSets)

## Dependencies

| Chart | Version | Repository |
|-------|---------|------------|
| postgresql | 12.x | bitnami |
| redis | 17.x | bitnami |
| clickhouse | 4.x | bitnami |

## Upgrading

```bash
# Update Helm repo
helm repo update

# Upgrade release
helm upgrade iof iof/iof-platform -f values.yaml
```

## Uninstalling

```bash
helm uninstall iof
```

## Development

### Testing Charts

```bash
# Lint charts
helm lint ./charts/iof

# Dry run
helm install iof ./charts/iof --dry-run --debug

# Template rendering
helm template iof ./charts/iof
```

### Packaging

```bash
helm package ./charts/iof
helm package ./iof-platform
helm package ./tigerbeetle
```

## Support

- **Documentation**: https://docs.islamicopenfinance.com/deployment
- **GitHub Issues**: https://github.com/Islamic-Open-Finance/iof-helm-charts/issues

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.

---

**Built for the global Islamic finance ecosystem**
