#!/bin/bash
set -e

echo "[INFO] Deleting demo namespace and ArgoCD..."
kubectl delete ns gitops-demo || true
kubectl delete ns argocd || true

echo "[INFO] Teardown complete!"
