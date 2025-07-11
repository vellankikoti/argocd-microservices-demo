# Scenario 05: GitOps with ArgoCD & Argo Rollouts – Quick Handbook

## 🚀 Introduction
This scenario demonstrates GitOps best practices using ArgoCD and Argo Rollouts to manage a real microservices demo (Online Boutique). You’ll learn how to:
- Install and access ArgoCD
- Deploy and manage microservices with GitOps
- Use overlays for local/cloud/rollouts
- Demo canary, blue-green, and rolling deployments
- Use helper scripts for easy management

---

## 🛠️ Prerequisites
- Kubernetes cluster (Docker Desktop, minikube, kind, or cloud)
- `kubectl` configured for your cluster
- [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/) (optional, for advanced usage)
- [Argo Rollouts plugin](https://argoproj.github.io/argo-rollouts/installation/) (for advanced rollout UI)

---

## 1️⃣ Cluster Setup (Local or Cloud)
- **Local:** Use Docker Desktop, minikube, or kind
- **Cloud:** GKE, EKS, AKS, etc.

---

## 2️⃣ Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

---

## 3️⃣ Access ArgoCD UI
- **Port-forward (local):**
  ```bash
  kubectl port-forward svc/argocd-server -n argocd 8080:443
  # Visit http://localhost:8080
  ```
- **Cloud:** Use LoadBalancer/Ingress URL

---

## 4️⃣ Get ArgoCD Admin Password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```
- **Username:** `admin`
- **Password:** (output from above)

---

## 5️⃣ Bootstrap the App-of-Apps
```bash
kubectl apply -f argocd-apps/app-of-apps.yaml
```
- This creates all child Applications for each microservice.

---

## 6️⃣ Deploy the Microservices Demo
- ArgoCD will sync all Applications automatically.
- Watch the status in the ArgoCD UI (Applications tab).

---

## 7️⃣ Access the Demo App
- **Local:**
  - `http://localhost:30080` (NodePort overlay)
- **Cloud:**
  - Use the LoadBalancer IP for the frontend service

---

## 8️⃣ Switch Overlays (Local/Cloud/Rollouts)
- Use the helper script:
  ```bash
  ./scripts/switch-overlay.sh local      # For local NodePort
  ./scripts/switch-overlay.sh cloud      # For cloud LoadBalancer
  ./scripts/switch-overlay.sh rollouts   # For advanced rollout strategies
  ```
- Sync Applications in ArgoCD UI after switching overlays.

---

## 9️⃣ Demonstrate Deployment Strategies
- **Canary (frontend):**
  - Update the image/tag in the rollout manifest and sync in ArgoCD.
  - Watch canary steps in ArgoCD and (optionally) Argo Rollouts UI.
- **Blue-Green (recommendationservice):**
  - Update the image/tag and sync. Preview and promote in Argo Rollouts UI.
- **Rolling (other services):**
  - Update image/tag and sync for standard rolling update.

---

## 🔟 Use Argo Rollouts UI (Optional)
- Install dashboard:
  ```bash
  kubectl apply -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
  kubectl -n argo-rollouts port-forward deployment/argo-rollouts-dashboard 3100:3100
  # Visit http://localhost:3100
  ```

---

## 1️⃣1️⃣ Helper Scripts
- `./scripts/setup.sh` – Install ArgoCD, bootstrap app-of-apps
- `./scripts/teardown.sh` – Remove all resources
- `./scripts/switch-overlay.sh` – Switch overlays
- `./scripts/reset-demo.sh` – Reset demo environment

---

## 1️⃣2️⃣ Troubleshooting
- **Pods not starting?** Check resource limits and cluster size.
- **ArgoCD sync errors?** Check Application manifest paths and overlay usage.
- **Rollouts not visible?** Ensure Argo Rollouts CRDs and dashboard are installed.
- **Overlay not switching?** Make sure to sync in ArgoCD UI after running the script.

---

## 1️⃣3️⃣ Quick Reference Commands
```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

# Port-forward ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Bootstrap app-of-apps
kubectl apply -f argocd-apps/app-of-apps.yaml

# Switch overlays
./scripts/switch-overlay.sh local|cloud|rollouts

# Reset demo
demo/scripts/reset-demo.sh
```

---

## 1️⃣4️⃣ Folder Structure
```
05-gitops/
  argocd-apps/
    app-of-apps.yaml
    apps/
      frontend.yaml
      recommendationservice.yaml
      ...
  overlays/
    local/
    cloud/
    rollouts/
  services/
    adservice/
    cartservice/
    ...
  scripts/
    setup.sh
    teardown.sh
    switch-overlay.sh
    reset-demo.sh
```

---

## 1️⃣5️⃣ Credits & References
- [GoogleCloudPlatform/microservices-demo](https://github.com/GoogleCloudPlatform/microservices-demo)
- [ArgoCD](https://argo-cd.readthedocs.io/)
- [Argo Rollouts](https://argoproj.github.io/argo-rollouts/) 