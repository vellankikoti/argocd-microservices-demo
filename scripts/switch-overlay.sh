#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 [local|cloud|rollouts]"
  exit 1
fi

OVERLAY=$1
APPS_DIR="../argocd-apps/apps"

case $OVERLAY in
  local|cloud|rollouts)
    echo "[INFO] Switching all Application manifests to overlays/$OVERLAY..."
    for app in $APPS_DIR/*.yaml; do
      sed -i  "s|path: overlays/.*|path: overlays/$OVERLAY|" "$app"
    done
    echo "[INFO] Overlay switched to $OVERLAY. Please sync in ArgoCD UI."
    ;;
  *)
    echo "Invalid overlay: $OVERLAY. Use local, cloud, or rollouts."
    exit 1
    ;;
esac
