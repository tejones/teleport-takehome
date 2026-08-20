# Teleport Customer Solutions Take-Home Exercise

This repository documents a three-node Kubernetes environment built for
Teleport's Customer Solutions technical exercise.

The implementation demonstrates Kubernetes certificate-based authentication,
least-privilege RBAC, application deployment using a restricted identity,
Ingress-based application access, and TLS certificate issuance with
cert-manager.

## Objectives

- Build a three-node Kubernetes cluster using kubeadm
- Use one control-plane node and two worker nodes
- Configure certificate-based Kubernetes user authentication
- Implement namespace-scoped least-privilege RBAC
- Deploy Nginx as a restricted user rather than the cluster administrator
- Serve a static peach cheesecake recipe
- Use cert-manager to issue the application's TLS certificate
- Expose the application through ingress-nginx
- Make the application reachable from a browser over HTTPS

## Environment

| Component | Version / Configuration |
|---|---|
| Host | Apple Silicon Mac / UTM |
| Guest OS | Ubuntu Server 24.04.4 LTS ARM64 |
| Kubernetes | v1.35.7 |
| Runtime | containerd 2.2.1 |
| CNI | Calico |
| Control Plane | k8s-control - 192.168.64.5 |
| Worker 1 | k8s-worker1 - 192.168.64.6 |
| Worker 2 | k8s-worker2 - 192.168.64.7 |
| Ingress | ingress-nginx |
| TLS | cert-manager |

## Architecture

```text
Mac Workstation
     |
     | app-deployer X.509 certificate
     |
     +--------------------> Kubernetes API
     |                           |
     |                           v
     |                    Namespace RBAC
     |                           |
     |                           v
     |                      nginx-app
     |
     | HTTPS
     v
peach-cheesecake.local:31537
     |
     v
ingress-nginx
     |
     | TLS certificate issued by cert-manager
     v
peach-cheesecake Service
     |
     v
Nginx Deployment
     |
     +---- Nginx Pod
     |
     +---- Nginx Pod
```

## Cluster

The Kubernetes cluster was created with `kubeadm` rather than a local
development wrapper such as Minikube or Kind.

Calico provides pod networking.

```text
k8s-control   192.168.64.5   control-plane
k8s-worker1   192.168.64.6   worker
k8s-worker2   192.168.64.7   worker
```

## Authentication

The `app-deployer` identity uses an X.509 client certificate requested through
the Kubernetes CertificateSigningRequest API.

The certificate identity is:

```text
CN = app-deployer
O  = app-deployers
```

The client certificate was requested with a 24-hour lifetime.

The private key was generated on the client workstation and was never
transferred to the Kubernetes nodes or committed to this repository.

## Authorization

Authentication does not grant application permissions.

A namespace-scoped Kubernetes Role and RoleBinding authorize `app-deployer`
only for the resources required to manage the application in `nginx-app`.

The authorization model was explicitly tested:

```text
List pods in nginx-app:   yes
List pods in default:     no
List cluster nodes:       no
```

The identity was also denied `pods/portforward`, demonstrating that capabilities
not explicitly required by the application were not granted.

## Separation of Responsibilities

Cluster infrastructure is managed administratively.

Administrator responsibilities:
- Kubernetes cluster bootstrap
- Calico
- cert-manager
- ingress-nginx
- ClusterIssuer
- namespace creation
- RBAC policy

`app-deployer` responsibilities:
- ConfigMap
- Deployment
- Service
- Ingress

## Application

The application consists of:
- Nginx
- Two replicas
- ConfigMap-hosted static HTML
- ClusterIP Service
- ingress-nginx Ingress
- Peach cheesecake recipe

The application resources were deployed using the restricted `app-deployer`
identity rather than `kubernetes-admin`.

## TLS

cert-manager manages the TLS certificate used by the application Ingress.

For this private UTM lab, a self-signed ClusterIssuer is used rather than a
public ACME provider. The environment uses private RFC1918 addresses and is
not publicly DNS-addressable.

The generated certificate is stored in the Kubernetes TLS Secret:

```text
peach-cheesecake-tls
```

## Browser Access

The ingress-nginx controller exposes HTTPS using NodePort `31537`.

The Mac workstation maps the application hostname to a worker node in
`/etc/hosts`:

```text
192.168.64.6 peach-cheesecake.local
```

The application is available at:

```text
https://peach-cheesecake.local:31537
```

Because the lab uses a self-signed issuer, clients must explicitly trust the
lab certificate authority or accept the certificate for testing.

## Repository Structure

```text
kubernetes/
├── cert-manager/
│   └── clusterissuer.yaml
├── ingress/
│   └── ingress.yaml
├── nginx/
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── rbac/
│   ├── app-deployer-csr.yaml
│   ├── app-deployer-role.yaml
│   └── app-deployer-rolebinding.yaml
└── namespace.yaml

AI_DISCLOSURE.md
DESIGN.md
README.md
```

## Security

Private keys, kubeconfigs, certificates, CSRs, bootstrap tokens, and other
local credentials are excluded from source control.

The implementation intentionally separates authentication, authorization, and
application access rather than treating possession of Kubernetes credentials
as equivalent to administrative access.

## Status

- [x] Three-node kubeadm Kubernetes cluster
- [x] Calico networking
- [x] All nodes Ready
- [x] Restricted Kubernetes user
- [x] CSR-based certificate authentication
- [x] Namespace-scoped RBAC
- [x] Nginx deployment as restricted user
- [x] Peach cheesecake static site
- [x] cert-manager TLS certificate
- [x] ingress-nginx
- [x] Browser-accessible HTTPS endpoint
- [ ] Clean-environment reproducibility validation

## AI Assistance

AI assistance was used during development of this exercise.

See [AI_DISCLOSURE.md](AI_DISCLOSURE.md) for file-level disclosure.
