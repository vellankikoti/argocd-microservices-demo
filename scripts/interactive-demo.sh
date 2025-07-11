#!/bin/bash

# 🚀 Interactive GitOps Deployment Strategies Demo
# This script provides an elevated learning experience with visual feedback

set -e

# Colors for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${CYAN}🔄 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header() {
    echo -e "${PURPLE}🎯 $1${NC}"
    echo "=================================================="
}

# Function to wait for user input
wait_for_user() {
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read -r
}

# Function to check if Argo Rollouts is installed
check_argo_rollouts() {
    if ! kubectl get crd rollouts.argoproj.io >/dev/null 2>&1; then
        print_error "Argo Rollouts not installed. Installing now..."
        kubectl apply -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
        kubectl apply -f https://github.com/argoproj/argo-rollouts/releases/latest/download/dashboard-install.yaml
        print_success "Argo Rollouts installed successfully!"
    else
        print_success "Argo Rollouts already installed!"
    fi
}

# Function to start dashboards
start_dashboards() {
    print_step "Starting ArgoCD and Argo Rollouts dashboards..."
    
    # Start ArgoCD dashboard
    kubectl port-forward svc/argocd-server -n argocd 8080:443 &
    ARGOCD_PID=$!
    
    # Start Argo Rollouts dashboard
    kubectl port-forward deployment/argo-rollouts-dashboard -n argo-rollouts 3100:3100 &
    ROLLOUTS_PID=$!
    
    sleep 3
    
    print_success "Dashboards started!"
    print_info "ArgoCD UI: http://localhost:8080 (admin/$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d))"
    print_info "Argo Rollouts UI: http://localhost:3100"
    
    wait_for_user
}

# Function to demonstrate Canary Deployment
demo_canary_deployment() {
    print_header "🎭 CANARY DEPLOYMENT DEMO"
    print_info "This demo shows gradual traffic shifting with automated health checks"
    
    print_step "1. Deploying frontend with Canary strategy..."
    kubectl apply -f overlays/rollouts/frontend-rollout.yaml
    kubectl apply -f overlays/rollouts/frontend-preview-service.yaml
    
    print_step "2. Watching the canary deployment progress..."
    echo "Open Argo Rollouts UI: http://localhost:3100"
    echo "Watch the traffic gradually shift from 25% → 50% → 75% → 100%"
    
    kubectl rollout status rollout/frontend -n gitops-demo --watch &
    ROLLOUT_WATCH_PID=$!
    
    wait_for_user
    
    print_step "3. Testing the canary deployment..."
    print_info "Stable version (port 30081):"
    curl -s http://localhost:30081 | grep -i "online boutique" | head -1 || echo "Service not ready yet"
    
    print_info "Canary version (port 30082):"
    curl -s http://localhost:30082 | grep -i "online boutique" | head -1 || echo "Service not ready yet"
    
    wait_for_user
    
    # Kill the watch process
    kill $ROLLOUT_WATCH_PID 2>/dev/null || true
}

# Function to demonstrate Blue-Green Deployment
demo_blue_green_deployment() {
    print_header "🔵🔴 BLUE-GREEN DEPLOYMENT DEMO"
    print_info "This demo shows zero-downtime deployment with automatic rollback"
    
    print_step "1. Deploying recommendationservice with Blue-Green strategy..."
    kubectl apply -f overlays/rollouts/recommendationservice-rollout.yaml
    kubectl apply -f overlays/rollouts/recommendationservice-preview-service.yaml
    
    print_step "2. Watching the blue-green deployment..."
    echo "Open Argo Rollouts UI: http://localhost:3100"
    echo "Watch the blue (stable) and green (preview) environments"
    
    kubectl rollout status rollout/recommendationservice -n gitops-demo --watch &
    ROLLOUT_WATCH_PID=$!
    
    wait_for_user
    
    print_step "3. Promoting the green environment..."
    print_info "Before promotion - Blue (active) vs Green (preview)"
    kubectl get pods -n gitops-demo | grep recommendationservice
    
    print_warning "Promoting green to blue (this will switch traffic)..."
    kubectl argo rollouts promote recommendationservice -n gitops-demo
    
    wait_for_user
    
    print_info "After promotion - New blue (active) vs Old blue (scaling down)"
    kubectl get pods -n gitops-demo | grep recommendationservice
    
    wait_for_user
    
    # Kill the watch process
    kill $ROLLOUT_WATCH_PID 2>/dev/null || true
}

# Function to demonstrate Rolling Update
demo_rolling_update() {
    print_header "🔄 ROLLING UPDATE DEMO"
    print_info "This demo shows zero-downtime rolling updates"
    
    print_step "1. Current deployment status..."
    kubectl get deployment frontend -n gitops-demo
    kubectl get pods -n gitops-demo | grep frontend
    
    print_step "2. Triggering rolling update..."
    print_warning "Updating frontend image to trigger rolling update..."
    kubectl set image deployment/frontend server=us-central1-docker.pkg.dev/google-samples/microservices-demo/frontend:v0.10.3 -n gitops-demo
    
    print_step "3. Watching rolling update progress..."
    kubectl rollout status deployment/frontend -n gitops-demo --watch &
    ROLLOUT_WATCH_PID=$!
    
    wait_for_user
    
    print_step "4. Testing application during update..."
    print_info "Application should remain accessible during the update"
    curl -s http://localhost:30081 | grep -i "online boutique" | head -1 || echo "Service not ready yet"
    
    wait_for_user
    
    # Kill the watch process
    kill $ROLLOUT_WATCH_PID 2>/dev/null || true
}

# Function to demonstrate rollback
demo_rollback() {
    print_header "🔄 ROLLBACK DEMO"
    print_info "This demo shows how to rollback to previous versions"
    
    print_step "1. Current rollout history..."
    kubectl rollout history rollout/frontend -n gitops-demo
    
    print_step "2. Simulating a bad deployment..."
    print_warning "This would normally be a bad image or configuration..."
    print_info "In real scenarios, you'd deploy a problematic version"
    
    wait_for_user
    
    print_step "3. Rolling back to previous version..."
    print_warning "Rolling back to previous stable version..."
    kubectl rollout undo rollout/frontend -n gitops-demo
    
    print_step "4. Watching rollback progress..."
    kubectl rollout status rollout/frontend -n gitops-demo --watch &
    ROLLOUT_WATCH_PID=$!
    
    wait_for_user
    
    # Kill the watch process
    kill $ROLLOUT_WATCH_PID 2>/dev/null || true
}

# Function to show monitoring and metrics
show_monitoring() {
    print_header "📊 MONITORING & METRICS"
    
    print_step "1. ArgoCD Application status..."
    kubectl get applications -n argocd
    
    print_step "2. Rollout status..."
    kubectl get rollouts -n gitops-demo
    
    print_step "3. Pod status..."
    kubectl get pods -n gitops-demo
    
    print_step "4. Service endpoints..."
    kubectl get services -n gitops-demo | grep -E "(frontend|recommendationservice)"
    
    print_info "For detailed metrics, visit:"
    print_info "- ArgoCD UI: http://localhost:8080"
    print_info "- Argo Rollouts UI: http://localhost:3100"
    
    wait_for_user
}

# Main demo function
main() {
    print_header "🚀 INTERACTIVE GITOPS DEPLOYMENT STRATEGIES DEMO"
    print_info "This demo provides an elevated learning experience with visual feedback"
    print_info "You'll see real-time deployment progress, traffic shifting, and rollback scenarios"
    
    wait_for_user
    
    # Check prerequisites
    print_step "Checking prerequisites..."
    check_argo_rollouts
    
    # Start dashboards
    start_dashboards
    
    # Run demos
    demo_canary_deployment
    demo_blue_green_deployment
    demo_rolling_update
    demo_rollback
    show_monitoring
    
    print_header "🎉 DEMO COMPLETE!"
    print_success "You've experienced:"
    print_success "- Canary deployments with gradual traffic shifting"
    print_success "- Blue-green deployments with zero downtime"
    print_success "- Rolling updates with automatic health checks"
    print_success "- Rollback capabilities for failed deployments"
    print_success "- Real-time monitoring and visualization"
    
    print_info "Keep the dashboards open to continue exploring:"
    print_info "- ArgoCD UI: http://localhost:8080"
    print_info "- Argo Rollouts UI: http://localhost:3100"
    
    # Cleanup function
    cleanup() {
        print_warning "Cleaning up background processes..."
        kill $ARGOCD_PID 2>/dev/null || true
        kill $ROLLOUTS_PID 2>/dev/null || true
        print_success "Cleanup complete!"
    }
    
    trap cleanup EXIT
}

# Run the main function
main "$@" 