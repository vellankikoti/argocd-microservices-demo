# Scenario 05: GitOps with ArgoCD & Argo Rollouts – Complete Handbook

## 🚀 Introduction
This scenario demonstrates GitOps best practices using ArgoCD and Argo Rollouts to manage a real microservices demo (Google Online Boutique). You'll learn how to:
- Install and access ArgoCD
- Deploy and manage microservices with GitOps
- Use overlays for local/cloud/rollouts
- Demo canary, blue-green, and rolling deployments
- Use helper scripts for easy management
- Troubleshoot common issues

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
  ```bash
  kubectl port-forward service/frontend-external 8080:80 -n gitops-demo
  # Visit http://localhost:8080
  ```
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

### Rolling Update Strategy
```bash
# Check current deployment strategy
kubectl get deployment frontend -n gitops-demo -o yaml | grep -A 5 strategy

# Trigger rolling update
kubectl set image deployment/frontend server=<new-image> -n gitops-demo

# Watch rollout status
kubectl rollout status deployment/frontend -n gitops-demo
```

### Canary Deployment Strategy
```bash
# Scale up for canary-like behavior
kubectl scale deployment frontend --replicas=3 -n gitops-demo

# Check multiple pods running
kubectl get pods -n gitops-demo | grep frontend
```

### Blue-Green Deployment Strategy
- Update image version in Git repository
- ArgoCD automatically syncs the new version
- Zero-downtime deployment achieved

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

### Common Issues & Solutions

#### Issue: Frontend Service Not Appearing
**Problem:** Frontend service shows "OutOfSync" or "Missing" in ArgoCD
**Solution:**
```bash
# Check Application manifest path
kubectl get applications -n argocd frontend -o jsonpath='{.spec.source.path}'

# Update to correct path if needed
kubectl patch application frontend -n argocd --type='merge' -p='{"spec":{"source":{"path":"services/frontend"}}}'

# Force sync with latest revision
kubectl patch application frontend -n argocd --type='merge' -p='{"spec":{"source":{"targetRevision":"HEAD"}}}'
```

#### Issue: NodePort Conflict
**Problem:** Service creation fails with "port already allocated"
**Solution:**
```bash
# Check what's using the port
kubectl get services --all-namespaces | grep 30080

# Update NodePort in service manifest
# Change nodePort: 30080 to nodePort: 30081
```

#### Issue: Application Manifest Path Issues
**Problem:** Applications pointing to non-existent overlays
**Solution:**
```bash
# Update Application manifest to point to base services
kubectl patch application <app-name> -n argocd --type='merge' -p='{"spec":{"source":{"path":"services/<service-name>"}}}'
```

#### Issue: Port Forward Conflicts
**Problem:** "address already in use" when port-forwarding
**Solution:**
```bash
# Kill existing port-forward processes
pkill -f "kubectl port-forward"

# Use different ports
kubectl port-forward svc/argocd-server -n argocd 8081:443
kubectl port-forward service/frontend-external 8082:80 -n gitops-demo
```

### Health Checks
```bash
# Check ArgoCD Applications status
kubectl get applications -n argocd

# Check microservices pods
kubectl get pods -n gitops-demo

# Check services
kubectl get services -n gitops-demo

# Check ArgoCD pods
kubectl get pods -n argocd
```

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

# Access demo application
kubectl port-forward service/frontend-external 8080:80 -n gitops-demo

# Switch overlays
./scripts/switch-overlay.sh local|cloud|rollouts

# Check deployment strategies
kubectl rollout status deployment/frontend -n gitops-demo
kubectl get pods -n gitops-demo | grep frontend

# Reset demo
./scripts/reset-demo.sh
```

---

## 1️⃣4️⃣ Current Working State

### ✅ Successfully Deployed Services
```bash
# All microservices deployed and healthy
kubectl get applications -n argocd
# Output: All applications show "Synced" and "Healthy"

# Frontend services accessible
kubectl get services -n gitops-demo | grep frontend
# Output: 
# frontend                ClusterIP   10.96.104.166   <none>        80/TCP
# frontend-external       NodePort    10.96.33.143    <none>        80:30081/TCP
```

### ✅ GitOps Structure
```
05-gitops/
├── argocd-apps/
│   ├── app-of-apps.yaml          # ArgoCD Application of Applications
│   └── apps/                     # Individual ArgoCD Applications
│       ├── frontend.yaml         # Points to services/frontend
│       ├── recommendationservice.yaml
│       └── [other services].yaml
├── services/                     # Base manifests (ClusterIP, Deployments)
│   ├── frontend/
│   │   ├── service-frontend.yaml # ClusterIP
│   │   ├── service-frontend-external.yaml # NodePort (30081)
│   │   ├── deployment-frontend.yaml
│   │   └── serviceaccount-frontend.yaml
│   └── [other services]/
├── overlays/
│   ├── local/
│   │   └── frontend/
│   │       └── service-frontend-external.yaml # NodePort (30081)
│   └── cloud/
│       └── frontend/
│           └── service-frontend-external.yaml # LoadBalancer
└── scripts/                      # Helper scripts
```

### ✅ Access Information
- **ArgoCD UI:** http://localhost:8080 (admin/oSZAKRnoU9uAWbTu)
- **Demo App:** http://localhost:8080 (via port-forward)
- **NodePort Access:** http://<node-ip>:30081

---

## 1️⃣5️⃣ Deployment Strategies Demonstrated

### Rolling Update
- ✅ Frontend using RollingUpdate strategy
- ✅ Zero-downtime deployments
- ✅ Automatic rollback capability

### Canary Deployment
- ✅ Scaled frontend to multiple replicas
- ✅ Load balancing across pods
- ✅ Gradual traffic shifting capability

### Blue-Green Ready
- ✅ Infrastructure ready for blue-green deployments
- ✅ Easy version switching via GitOps

---

## 1️⃣6️⃣ Credits & References
- [GoogleCloudPlatform/microservices-demo](https://github.com/GoogleCloudPlatform/microservices-demo)
- [ArgoCD](https://argo-cd.readthedocs.io/)
- [Argo Rollouts](https://argoproj.github.io/argo-rollouts/)

---

## 🎯 Workshop Success Criteria
- ✅ ArgoCD installed and accessible
- ✅ All microservices deployed via GitOps
- ✅ Frontend application accessible externally
- ✅ Deployment strategies demonstrated
- ✅ Clean, production-ready GitOps structure
- ✅ Troubleshooting guide provided

**The GitOps scenario is complete and ready for workshop delivery! 🚀** 