# Teleport Customer Solutions Take-Home Exercise

This repository contains a reproducible Kubernetes deployment created for
Teleport's Customer Solutions technical exercise.

## Objectives

- Build a three-node Kubernetes cluster using kubeadm
- One control-plane node and two worker nodes
- Configure Kubernetes certificate-based user authentication
- Implement namespace-scoped RBAC
- Deploy Nginx using the restricted user rather than the cluster administrator
- Serve a static site containing a peach cheesecake recipe
- Use cert-manager to issue the TLS certificate
- Make the application reachable from a web browser
- Document architecture, security decisions, tradeoffs, and deployment steps

## Environment

| Component | Version / Configuration |
|---|---|
| Host | Apple Silicon / UTM |
| Guest OS | Ubuntu Server 24.04.4 LTS ARM64 |
| Kubernetes | v1.35.7 |
| Runtime | containerd 2.2.1 |
| CNI | Calico |
| Control Plane | k8s-control - 192.168.64.5 |
| Worker 1 | k8s-worker1 - 192.168.64.6 |
| Worker 2 | k8s-worker2 - 192.168.64.7 |

## Architecture

The cluster is built using kubeadm rather than a Kubernetes development
wrapper such as Minikube or Kind.

Application access will demonstrate:

User Certificate
    |
Kubernetes API
    |
RBAC Role / RoleBinding
    |
Application Namespace
    |
Nginx Deployment
    |
Service / Ingress
    |
TLS via cert-manager
    |
Browser

## Repository Structure

- `scripts/` - reproducible node and Kubernetes installation procedures
- `kubernetes/rbac/` - namespace and RBAC configuration
- `kubernetes/nginx/` - application manifests and site content
- `kubernetes/cert-manager/` - certificate configuration
- `kubernetes/ingress/` - browser exposure
- `docs/` - architecture and demonstration material
- `optional/` - advanced objectives
- `AI_DISCLOSURE.md` - required AI assistance disclosure

## Security

Generated private keys, kubeconfigs, bootstrap tokens, certificates, and other
credentials are intentionally excluded from source control.

## Status

- [x] Three-node kubeadm Kubernetes cluster
- [x] Calico networking
- [x] All nodes Ready
- [ ] Restricted Kubernetes user
- [ ] CSR-based certificate authentication
- [ ] Namespace-scoped RBAC
- [ ] Nginx application deployment as restricted user
- [ ] Peach cheesecake static site
- [ ] cert-manager TLS certificate
- [ ] Browser-accessible HTTPS endpoint
- [ ] Clean-environment reproducibility validation
