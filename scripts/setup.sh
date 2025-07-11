#!/bin/bash
set -e

echo "[INFO] Installing ArgoCD..."
kubectl create namespace argocd || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sleep 10
echo "[INFO] Bootstrapping app-of-apps..."
kubectl apply -f ../argocd-apps/app-of-apps.yaml

echo "[INFO] Setup complete!"
echo "- ArgoCD UI: http://localhost:8080 (port-forward if needed)"
echo "- Demo app: http://localhost:30080 (NodePort overlay)"
