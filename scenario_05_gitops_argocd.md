# Scenario 05: GitOps with ArgoCD & Argo Rollouts – Complete Handbook

## 🚀 Introduction
This scenario demonstrates GitOps best practices using ArgoCD and Argo Rollouts to manage a real microservices demo (Google Online Boutique). You'll learn how to:
- Install and access ArgoCD and Argo Rollouts
- Deploy and manage microservices with GitOps
- Use overlays for local/cloud/rollouts
- **Experience interactive deployment strategies with visual feedback**
- **Demo canary, blue-green, and rolling deployments with real-time monitoring**
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

## 2️⃣ Install ArgoCD & Argo Rollouts
```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install Argo Rollouts (for advanced deployment strategies)
kubectl apply -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
kubectl apply -f https://github.com/argoproj/argo-rollouts/releases/latest/download/dashboard-install.yaml
```

---

## 3️⃣ Access Dashboards
- **ArgoCD UI (Port-forward):**
  ```bash
  kubectl port-forward svc/argocd-server -n argocd 8080:443
  # Visit http://localhost:8080
  ```
- **Argo Rollouts UI (Port-forward):**
  ```bash
  kubectl port-forward deployment/argo-rollouts-dashboard -n argo-rollouts 3100:3100
  # Visit http://localhost:3100
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

## 8️⃣ 🎭 **INTERACTIVE DEPLOYMENT STRATEGIES DEMO**

### **Quick Start - Elevated Learning Experience**
```bash
# Run the interactive demo with visual feedback
./scripts/interactive-demo.sh
```

### **What You'll Experience:**

#### **🎭 Canary Deployment (Frontend)**
- **Visual Progress**: Watch traffic gradually shift from 25% → 50% → 75% → 100%
- **Health Monitoring**: Automated checks ensure new version is healthy
- **Traffic Testing**: Test both stable and canary versions simultaneously
- **Real-time Feedback**: See deployment progress in Argo Rollouts UI

#### **🔵🔴 Blue-Green Deployment (Recommendationservice)**
- **Environment Switching**: Watch blue (stable) and green (preview) environments
- **Zero Downtime**: Traffic switches instantly between environments
- **Manual Promotion**: Control when to promote the green environment
- **Automatic Rollback**: Failed deployments automatically rollback

#### **🔄 Rolling Update Demo**
- **Pod-by-Pod Updates**: See pods update one by one
- **Health Checks**: Automatic verification of each pod
- **Zero Downtime**: Application remains accessible throughout
- **Rollback Capability**: Easy rollback to previous version

#### **📊 Real-time Monitoring**
- **ArgoCD Dashboard**: Application health and sync status
- **Argo Rollouts Dashboard**: Deployment progress and traffic visualization
- **Health Metrics**: Success rates and error monitoring
- **Traffic Analysis**: See which version is serving traffic

---

## 9️⃣ Manual Deployment Strategy Demonstrations

### Canary Deployment Strategy
```bash
# Deploy with canary strategy
kubectl apply -f overlays/rollouts/frontend-rollout.yaml
kubectl apply -f overlays/rollouts/frontend-preview-service.yaml

# Watch progress in Argo Rollouts UI
# Visit http://localhost:3100

# Test different versions
curl http://localhost:30081  # Stable version
curl http://localhost:30082  # Canary version
```

### Blue-Green Deployment Strategy
```bash
# Deploy with blue-green strategy
kubectl apply -f overlays/rollouts/recommendationservice-rollout.yaml
kubectl apply -f overlays/rollouts/recommendationservice-preview-service.yaml

# Watch environments in Argo Rollouts UI
# Promote green to blue when ready
kubectl argo rollouts promote recommendationservice -n gitops-demo
```

### Rolling Update Strategy
```bash
# Check current deployment strategy
kubectl get deployment frontend -n gitops-demo -o yaml | grep -A 5 strategy

# Trigger rolling update
kubectl set image deployment/frontend server=<new-image> -n gitops-demo

# Watch rollout status
kubectl rollout status deployment/frontend -n gitops-demo
```

---

## 🔟 Switch Overlays (Local/Cloud/Rollouts)
- Use the helper script:
  ```bash
  ./scripts/switch-overlay.sh local      # For local NodePort
  ./scripts/switch-overlay.sh cloud      # For cloud LoadBalancer
  ./scripts/switch-overlay.sh rollouts   # For advanced rollout strategies
  ```
- Sync Applications in ArgoCD UI after switching overlays.

---

## 1️⃣1️⃣ Helper Scripts
- `./scripts/setup.sh` – Install ArgoCD, bootstrap app-of-apps
- `./scripts/teardown.sh` – Remove all resources
- `./scripts/switch-overlay.sh` – Switch overlays
- `./scripts/reset-demo.sh` – Reset demo environment
- **`./scripts/interactive-demo.sh`** – **Interactive deployment strategies demo**

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
kubectl patch application frontend -n argocd --type='merge' -p='{"spec":{"source":{"path":"overlays/rollouts"}}}'

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

#### Issue: Argo Rollouts Not Working
**Problem:** Rollouts not showing in dashboard
**Solution:**
```bash
# Check if Argo Rollouts is installed
kubectl get crd rollouts.argoproj.io

# Reinstall if needed
kubectl apply -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
kubectl apply -f https://github.com/argoproj/argo-rollouts/releases/latest/download/dashboard-install.yaml
```

#### Issue: Port Forward Conflicts
**Problem:** "address already in use" when port-forwarding
**Solution:**
```bash
# Kill existing port-forward processes
pkill -f "kubectl port-forward"

# Use different ports
kubectl port-forward svc/argocd-server -n argocd 8081:443
kubectl port-forward deployment/argo-rollouts-dashboard -n argo-rollouts 3101:3100
```

### Health Checks
```bash
# Check ArgoCD Applications status
kubectl get applications -n argocd

# Check microservices pods
kubectl get pods -n gitops-demo

# Check rollouts
kubectl get rollouts -n gitops-demo

# Check services
kubectl get services -n gitops-demo

# Check ArgoCD pods
kubectl get pods -n argocd
```

---

## 1️⃣3️⃣ Quick Reference Commands
```bash
# Install ArgoCD and Argo Rollouts
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
kubectl apply -f https://github.com/argoproj/argo-rollouts/releases/latest/download/dashboard-install.yaml

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

# Start dashboards
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
kubectl port-forward deployment/argo-rollouts-dashboard -n argo-rollouts 3100:3100 &

# Bootstrap app-of-apps
kubectl apply -f argocd-apps/app-of-apps.yaml

# Run interactive demo
./scripts/interactive-demo.sh

# Access demo application
kubectl port-forward service/frontend-external 8080:80 -n gitops-demo

# Switch overlays
./scripts/switch-overlay.sh local|cloud|rollouts

# Check deployment strategies
kubectl rollout status rollout/frontend -n gitops-demo
kubectl get rollouts -n gitops-demo

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
# frontend-preview        NodePort    10.96.45.123    <none>        80:30082/TCP
```

### ✅ Enhanced GitOps Structure
```
05-gitops/
├── argocd-apps/
│   ├── app-of-apps.yaml          # ArgoCD Application of Applications
│   └── apps/                     # Individual ArgoCD Applications
│       ├── frontend.yaml         # Points to overlays/rollouts
│       ├── recommendationservice.yaml # Points to overlays/rollouts
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
│   ├── cloud/
│   │   └── frontend/
│   │       └── service-frontend-external.yaml # LoadBalancer
│   └── rollouts/                 # Advanced deployment strategies
│       ├── frontend-rollout.yaml # Canary deployment
│       ├── frontend-preview-service.yaml
│       ├── recommendationservice-rollout.yaml # Blue-green deployment
│       ├── recommendationservice-preview-service.yaml
│       └── analysis-template.yaml # Health checks
├── scripts/
│   ├── interactive-demo.sh       # Interactive demo script
│   ├── setup.sh
│   ├── teardown.sh
│   ├── switch-overlay.sh
│   └── reset-demo.sh
└── ELEVATED_DEMO_GUIDE.md       # Comprehensive learning guide
```

### ✅ Access Information
- **ArgoCD UI:** http://localhost:8080 (admin/oSZAKRnoU9uAWbTu)
- **Argo Rollouts UI:** http://localhost:3100
- **Demo App:** http://localhost:8080 (via port-forward)
- **Stable Version:** http://localhost:30081
- **Canary Version:** http://localhost:30082

---

## 1️⃣5️⃣ Advanced Deployment Strategies Demonstrated

### Canary Deployment
- ✅ **Gradual Traffic Shifting**: 25% → 50% → 75% → 100%
- ✅ **Health Monitoring**: Automated success rate checks
- ✅ **Traffic Testing**: Test both versions simultaneously
- ✅ **Visual Progress**: Real-time dashboard monitoring

### Blue-Green Deployment
- ✅ **Environment Switching**: Blue (stable) vs Green (preview)
- ✅ **Zero Downtime**: Instant traffic switching
- ✅ **Manual Promotion**: Control when to promote
- ✅ **Automatic Rollback**: Safety for failed deployments

### Rolling Update
- ✅ **Pod-by-Pod Updates**: Gradual replacement
- ✅ **Health Checks**: Automatic verification
- ✅ **Zero Downtime**: Continuous service availability
- ✅ **Rollback Capability**: Quick recovery

---

## 1️⃣6️⃣ Educational Value

### **Lifetime Learning Experience**
- **Visual Learning**: Real-time dashboards and progress indicators
- **Interactive Demonstrations**: Guided step-by-step explanations
- **Hands-on Experience**: Direct interaction with deployment tools
- **Safety Mechanisms**: Learn without breaking production systems

### **Production-Ready Skills**
- **Advanced Deployment Strategies**: Canary, blue-green, rolling updates
- **GitOps Workflows**: Declarative infrastructure management
- **Monitoring Integration**: Health checks and metrics
- **Automation**: Automated deployment and rollback processes

---

## 1️⃣7️⃣ Credits & References
- [GoogleCloudPlatform/microservices-demo](https://github.com/GoogleCloudPlatform/microservices-demo)
- [ArgoCD](https://argo-cd.readthedocs.io/)
- [Argo Rollouts](https://argoproj.github.io/argo-rollouts/)

---

## 🎯 Workshop Success Criteria
- ✅ ArgoCD and Argo Rollouts installed and accessible
- ✅ All microservices deployed via GitOps
- ✅ Frontend application accessible externally
- ✅ **Interactive deployment strategies demonstrated with visual feedback**
- ✅ **Advanced deployment strategies (canary, blue-green) working**
- ✅ **Real-time monitoring and rollback capabilities**
- ✅ Clean, production-ready GitOps structure
- ✅ **Comprehensive troubleshooting guide provided**
- ✅ **Elevated learning experience with lifetime value**

**The GitOps scenario is complete and provides an elevated, interactive learning experience! 🚀** 