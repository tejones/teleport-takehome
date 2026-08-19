# Design

## Goals

The solution prioritizes:

1. Reproducibility
2. Least privilege
3. Clear separation of authentication and authorization
4. Simple troubleshooting
5. A deployment that can be explained clearly to a customer

## Kubernetes Architecture

The environment consists of one kubeadm control-plane node and two worker
nodes running Ubuntu Server on ARM64 virtual machines.

Calico provides the Kubernetes pod network.

## User Authentication

The application deployment user will authenticate to the Kubernetes API using
an X.509 client certificate issued through the Kubernetes
CertificateSigningRequest API.

The user's private key is generated outside the Kubernetes cluster and is not
stored in this repository.

## Authorization

Authentication establishes the user's identity.

Kubernetes RBAC determines what that identity may do.

The application user will receive only the namespace-scoped permissions
necessary to deploy, inspect, and maintain the Nginx application.

The demo will explicitly show both:

- operations the user is authorized to perform
- operations the user is not authorized to perform

## TLS

cert-manager will be used to issue the TLS certificate used by the Nginx
application endpoint.

## Tradeoffs

Kubernetes native certificate-based user management is useful for demonstrating
PKI, authentication, and RBAC, but it creates operational challenges around
certificate issuance, distribution, expiration, revocation, user lifecycle,
and auditing.

These limitations will be discussed during the demo.
