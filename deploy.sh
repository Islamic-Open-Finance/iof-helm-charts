#!/bin/bash
set -e

ENVIRONMENT=${1:-production}
NAMESPACE=${2:-iof}
RELEASE_NAME="iof-${ENVIRONMENT}"

echo "⎈ Deploying Islamic Open Finance Platform to Kubernetes"
echo "========================================================"
echo ""
echo "Environment: $ENVIRONMENT"
echo "Namespace: $NAMESPACE"
echo "Release: $RELEASE_NAME"
echo ""

# Add Helm repositories
echo "📦 Adding Helm repositories..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Update dependencies
echo "🔄 Updating Helm dependencies..."
helm dependency update infrastructure/helm

# Deploy
echo "🚀 Deploying Helm chart..."
helm upgrade --install $RELEASE_NAME infrastructure/helm \
  --namespace $NAMESPACE \
  --values infrastructure/helm/values.yaml \
  --values infrastructure/helm/values-${ENVIRONMENT}.yaml \
  --create-namespace \
  --wait \
  --timeout 10m

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Status:"
helm status $RELEASE_NAME --namespace $NAMESPACE

echo ""
echo "🔍 Pods:"
kubectl get pods --namespace $NAMESPACE

echo ""
echo "🌐 Services:"
kubectl get services --namespace $NAMESPACE

echo ""
echo "🔗 Ingresses:"
kubectl get ingress --namespace $NAMESPACE
