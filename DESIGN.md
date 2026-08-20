# Design

## Design Goals

The solution prioritizes:

1. Reproducibility
2. Least privilege
3. Separation of authentication and authorization
4. Clear administrative boundaries
5. Simple troubleshooting
6. A design that can be clearly explained to a customer

## Kubernetes Architecture

The environment consists of three Ubuntu Server ARM64 virtual machines running
in UTM:

- one kubeadm control-plane node
- two worker nodes

containerd provides the container runtime and Calico provides pod networking.

Using kubeadm exposes the underlying Kubernetes bootstrap and security model
rather than abstracting those details behind a local development distribution.

## Authentication

The application deployment identity, `app-deployer`, authenticates to the
Kubernetes API using an X.509 client certificate.

The private key is generated on the client workstation. A Certificate Signing
Request containing the public key and requested identity is submitted through
the Kubernetes CertificateSigningRequest API.

The requested identity is:

```text
CN = app-deployer
O  = app-deployers
```

The certificate was requested with a 24-hour lifetime.

The private key never needs to be transferred to the Kubernetes control plane.

## Authorization

Authentication establishes identity; it does not establish authorization.

A namespace-scoped Role and RoleBinding grant `app-deployer` the permissions
required to manage the Nginx application inside the `nginx-app` namespace.

Authorization testing demonstrated:

```text
app-deployer -> nginx-app pods    allowed
app-deployer -> default pods      denied
app-deployer -> cluster nodes     denied
app-deployer -> pod port-forward  denied
```

The port-forward denial was intentionally retained rather than expanding the
Role for testing convenience.

This demonstrates a default-deny, least-privilege approach: capabilities are
added because the application requires them, not because they may be useful.

## Separation of Responsibilities

Cluster infrastructure is managed administratively:

- cluster bootstrap
- networking
- ingress-nginx
- cert-manager
- ClusterIssuer
- namespace
- RBAC policy

Application resources are managed through `app-deployer`:

- ConfigMap
- Deployment
- Service
- Ingress

This keeps cluster-wide privileges separate from routine application
deployment privileges.

## Application

The Nginx application runs two replicas and serves static HTML containing a
peach cheesecake recipe.

The HTML is stored in a ConfigMap and mounted into the Nginx containers.

A ClusterIP Service provides stable internal access to the application.

An ingress-nginx Ingress provides external browser access.

## TLS

cert-manager issues the certificate consumed by the Nginx Ingress.

The lab uses a self-signed ClusterIssuer because the environment exists on
private UTM networking and does not have a publicly resolvable DNS name or
publicly reachable endpoint.

The application hostname is:

```text
peach-cheesecake.local
```

For browser access, the workstation maps that hostname to the worker node in
`/etc/hosts`.

## Security Tradeoffs

### Native Kubernetes client certificates

Kubernetes-native client certificates clearly demonstrate PKI authentication
and RBAC, but they create operational challenges at enterprise scale:

- certificate issuance
- secure credential distribution
- expiration and renewal
- revocation
- user lifecycle management
- credential inventory
- access auditing

The 24-hour certificate used here reduces the lifetime of a compromised
credential, but certificate lifecycle management remains an operational
responsibility.

### Self-signed application TLS

A self-signed issuer is appropriate for this isolated lab but would not be the
preferred approach for a public production service.

A production environment would normally use an organization-managed CA or an
ACME issuer such as Let's Encrypt, depending on organizational requirements.

### NodePort

NodePort provides a simple way to expose ingress-nginx from a local
bare-metal-style UTM cluster.

A production environment would typically use a load balancer or another
platform-appropriate ingress architecture.

## Teleport Relevance

The native Kubernetes implementation intentionally exposes several access
management challenges that become more significant as infrastructure scales.

Static or manually distributed Kubernetes credentials require organizations
to manage identity, certificate lifecycle, RBAC, revocation, and auditing
across environments.

Teleport can address this class of operational problem by centralizing
infrastructure identity and access, integrating with an identity provider,
using short-lived credentials, applying access policy consistently, and
providing an audit trail for infrastructure access.

The Kubernetes-native implementation in this exercise therefore provides both
a working security model and a baseline for discussing how that model changes
when managing many clusters, users, and environments.
