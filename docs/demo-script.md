# Teleport Take-Home Demo Runbook

## Purpose
This runbook supports the 15-minute presentation for the Teleport Customer Solutions technical exercise.

**Story:** Build -> Authenticate -> Authorize -> Deploy -> Secure -> Prove least privilege -> Connect to Teleport

## Pre-Interview Checklist
- [ ] UTM VMs running
- [ ] Three Kubernetes nodes Ready
- [ ] Calico, ingress-nginx, and cert-manager healthy
- [ ] Peach cheesecake deployment 2/2
- [ ] Ingress present and certificate Ready=True
- [ ] HTTPS site reachable from the Mac
- [ ] `/etc/hosts` maps `192.168.64.6 peach-cheesecake.local`
- [ ] Fresh 24-hour `app-deployer` certificate generated
- [ ] Restricted kubeconfig works
- [ ] `auth can-i` tests return yes / no / no
- [ ] Browser and repository ready
- [ ] `git status` clean
- [ ] `git ls-files credentials/` returns nothing

## Terminal Setup
Use two terminals to make the privilege boundary obvious.

**Terminal 1 — administrator**
```bash
ssh tejones@192.168.64.5
```

**Terminal 2 — restricted user**
```bash
cd ~/teleport-takehome
```
Use `--kubeconfig=credentials/app-deployer.kubeconfig`.

# 15-Minute Demo

## 0:00-1:30 — Architecture
Say:
> I approached this as both a Kubernetes implementation exercise and an access-management exercise. I used a three-node kubeadm cluster rather than Minikube or Kind so the authentication, authorization, networking, and certificate-management layers remained visible.

Show the README architecture and:
```bash
kubectl get nodes -o wide
```
Highlight Ubuntu 24.04 ARM64 on UTM, kubeadm, containerd, Calico, one control plane, and two workers.

## 1:30-4:00 — Authentication
Show `kubernetes/rbac/app-deployer-csr.yaml`.

Explain that `app-deployer` uses an X.509 client certificate requested through the Kubernetes CSR API:
```text
CN = app-deployer
O  = app-deployers
```
The private key was generated on the Mac, never transferred to a node, and excluded from Git. The certificate was requested with a 24-hour lifetime.

Transition:
> Authentication establishes identity. It does not determine authorization; Kubernetes RBAC does that.

## 4:00-6:30 — Authorization and Least Privilege
Show `app-deployer-role.yaml` and `app-deployer-rolebinding.yaml`.

From the Mac:
```bash
kubectl --kubeconfig=credentials/app-deployer.kubeconfig auth can-i list pods -n nginx-app
kubectl --kubeconfig=credentials/app-deployer.kubeconfig auth can-i list pods -n default
kubectl --kubeconfig=credentials/app-deployer.kubeconfig auth can-i list nodes
```
Expected:
```text
yes
no
no
```
Explain that port-forwarding was also denied because `pods/portforward` was not required. The Role was deliberately not broadened merely for testing convenience.

## 6:30-8:30 — Application
From the Mac:
```bash
kubectl --kubeconfig=credentials/app-deployer.kubeconfig   get pods,deployments,services,configmaps -n nginx-app
```
Highlight two Running Nginx replicas, the ClusterIP Service, and ConfigMap-hosted HTML.

Say:
> These resources were deployed from my workstation using `app-deployer`, not `kubernetes-admin`.

Briefly show `kubernetes/nginx/deployment.yaml`; highlight two replicas and the ConfigMap mount.

## 8:30-10:30 — Ingress and TLS
On the control plane:
```bash
kubectl get ingress -n nginx-app
kubectl get certificate,certificaterequest -n nginx-app
kubectl get secret peach-cheesecake-tls -n nginx-app
```
Highlight `READY=True` and Secret type `kubernetes.io/tls`.

Say:
> cert-manager issues the certificate consumed by the Ingress. Because this isolated UTM lab uses private RFC1918 networking and no public DNS, I used a self-signed issuer rather than pretending a public ACME issuer was appropriate.

## 10:30-11:30 — Browser
Open:
```text
https://peach-cheesecake.local:31537
```
Say:
> After all of that PKI and RBAC, we finally get our peach cheesecake.

Then explain: HTTPS -> ingress-nginx -> ClusterIP Service -> one of two Nginx pods.

## 11:30-13:00 — Reproducibility
Show:
```bash
find . -maxdepth 3 -type f | sort
```
Highlight `scripts/`, `kubernetes/`, `README.md`, `DESIGN.md`, and `AI_DISCLOSURE.md`.

Explain that node preparation, Kubernetes installation, control-plane initialization, worker joining, and platform components are documented without committing bootstrap tokens or credentials.

## 13:00-15:00 — Teleport Relevance
Say:
> The Kubernetes-native solution works, but implementing it exposes the operational access-management problem. I now have a private key and kubeconfig on my workstation, and someone must manage certificate issuance, distribution, expiration, renewal, revocation, RBAC, lifecycle, and auditing.

> That is manageable for one user and one cluster. It becomes much harder with dozens of clusters and hundreds of developers, SREs, and contractors.

> At that scale I would want centralized identity, IdP integration, short-lived credentials, consistently governed access, strong auditing, and just-in-time access instead of independently distributing static credentials or maintaining standing privileges.

Close:
> This implementation is both a working Kubernetes security model and a baseline for discussing how infrastructure access changes as an organization scales.

# Backup Commands

## Cluster
```bash
kubectl get nodes -o wide
kubectl get pods -A
```

## Application
```bash
kubectl get pods -n nginx-app
kubectl get deployment peach-cheesecake -n nginx-app
kubectl get svc peach-cheesecake -n nginx-app
kubectl get ingress peach-cheesecake -n nginx-app
```

## TLS
```bash
kubectl get certificate,certificaterequest -n nginx-app
kubectl describe certificate peach-cheesecake-tls -n nginx-app
kubectl get secret peach-cheesecake-tls -n nginx-app
```

## Platform
```bash
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
kubectl get pods -n cert-manager
```

# Troubleshooting Framework
Do not immediately change configuration.

1. Restate the symptom.
2. Establish scope.
3. Identify the layer involved.
4. Gather evidence.
5. Form a hypothesis.
6. Test it.
7. Explain the finding.
8. Propose the least disruptive fix.
9. Verify the fix.

For browser failures, work inward:
```text
Browser/DNS -> NodePort -> Ingress -> Service -> Endpoints -> Pods
```

# Do Not Spend Demo Time On
Unless asked, avoid spending significant time on UTM creation, Ubuntu installation, package-install output, every line of YAML, long `kubectl describe` output, basic Kubernetes definitions, or optional features. Emphasize decisions, security boundaries, evidence, and customer relevance.

# Likely Follow-Up Questions

**Why kubeadm?** It exposes the Kubernetes bootstrap, PKI, networking, and node model while remaining manageable for a small lab.

**Why a 24-hour certificate?** It limits credential lifetime and demonstrates short-lived access while exposing the lifecycle challenges of native client certificates.

**How would you revoke the user?** Remove or change RBAC immediately to remove authorization and rely on short certificate lifetime; native client-certificate lifecycle/revocation is one reason centralized identity systems are valuable.

**Why self-signed TLS?** The lab has private networking and no public DNS. Production would use an organization-managed CA or an appropriate ACME issuer.

**Why NodePort?** It is simple for a local bare-metal-style UTM cluster. Production would normally use an environment-appropriate load balancer or ingress architecture.

**Why deny port-forward?** It was not required. Adding it solely for testing would unnecessarily broaden permissions.

**What changes with many clusters?** Identity, credential lifecycle, RBAC consistency, revocation, auditing, and just-in-time access become substantially harder to manage independently.
