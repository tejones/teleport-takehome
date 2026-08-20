# AI Use Disclosure

AI tools were used during this exercise in accordance with the instructions
provided by Teleport.

## ChatGPT

ChatGPT was used as a collaborative technical assistant for:

- reviewing the take-home exercise requirements
- planning the lab architecture
- reviewing Kubernetes installation procedures
- troubleshooting the UTM virtual machine environment
- discussing kubeadm, containerd, Calico, Kubernetes PKI, RBAC, and security
- assisting with documentation structure and wording
- reviewing configuration files and commands as they are developed

## Files Created or Modified with AI Assistance

| File | Degree of Assistance |
|---|---|
| README.md | High - initial structure and wording drafted collaboratively with ChatGPT |
| DESIGN.md | High - initial structure and wording drafted collaboratively with ChatGPT |
| kubernetes/rbac/app-deployer-csr.yaml | High - Kubernetes CSR configuration developed with ChatGPT |
| kubernetes/namespace.yaml | High - namespace manifest developed with ChatGPT |
| kubernetes/rbac/app-deployer-role.yaml | High - namespace-scoped RBAC Role developed with ChatGPT |
| kubernetes/rbac/app-deployer-rolebinding.yaml | High - RBAC RoleBinding developed with ChatGPT |
| kubernetes/nginx/configmap.yaml | High - Nginx static site ConfigMap developed with ChatGPT |
| kubernetes/nginx/deployment.yaml | High - Nginx Deployment manifest developed with ChatGPT |
| kubernetes/nginx/service.yaml | High - Kubernetes Service manifest developed with ChatGPT |
| kubernetes/cert-manager/clusterissuer.yaml | High - cert-manager ClusterIssuer manifest developed with ChatGPT |
| kubernetes/ingress/ingress.yaml | High - Kubernetes Ingress manifest developed with ChatGPT |
| kubernetes/rbac/app-deployer-role.yaml | High - RBAC Role extended for Ingress permissions with ChatGPT |
| scripts/prepare-node.sh | High - Kubernetes node preparation script developed with ChatGPT |
| scripts/install-kubernetes.sh | High - Kubernetes and containerd installation script developed with ChatGPT |
| scripts/init-control-plane.sh | High - kubeadm control-plane initialization script developed with ChatGPT |
| scripts/join-worker.md | High - worker-node join procedure developed with ChatGPT |
| scripts/install-platform-components.sh | High - Calico, cert-manager, and ingress-nginx installation script developed with ChatGPT |
| AI_DISCLOSURE.md | High - initial wording drafted with ChatGPT |

Additional files will be added to this table as AI assistance is used.

All commands and configurations are executed, validated, and understood by the
