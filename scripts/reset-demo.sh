#!/bin/bash
set -e

echo "[INFO] Resetting demo environment..."
kubectl delete -f ../argocd-apps/app-of-apps.yaml || true
sleep 5
kubectl apply -f ../argocd-apps/app-of-apps.yaml

echo "[INFO] Demo environment reset!"
