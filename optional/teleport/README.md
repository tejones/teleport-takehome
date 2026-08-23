# Optional Teleport Integration

This directory documents the optional Teleport objective for the Customer Solutions take-home exercise.

The goal was to prove end-to-end Kubernetes access through Teleport using MFA-backed, short-lived identity and least-privilege Kubernetes authorization.

## Architecture

```text
Mac workstation
      |
      | tsh login + password + OTP
      v
Teleport Proxy
teleport.local:31546
      |
      v
Teleport Auth / Kubernetes Service
      |
      | short-lived Teleport identity
      | Kubernetes group: teleport-app-deployers
      v
Kubernetes API
      |
      v
RoleBinding in nginx-app
      |
      v
Existing app-deployer Role
```

## Components

- Teleport Community Edition 18.10.7
- `teleport-cluster` Helm chart 18.10.7
- standalone chart mode
- Teleport Auth, Proxy, and Kubernetes Services
- NodePort exposure for the UTM lab
- local OTP authentication
- static local PersistentVolume for Auth state

## Files

- `values.yaml` — Helm values for the standalone deployment
- `pv.yaml` — static 10 GiB local PersistentVolume
- `app-deployer-role.yaml` — Teleport role defining access to `nginx-app`
- `app-deployer-rolebinding.yaml` — Kubernetes RoleBinding mapping the Teleport Kubernetes group to the existing namespace Role

## Storage

The kubeadm lab has no dynamic StorageClass. The Teleport standalone chart requires persistent Auth storage, so the lab uses a static 10 GiB local PersistentVolume backed by:

```text
/var/lib/teleport-data
```

on `k8s-worker1`.

This is a lab-specific choice. Production should use platform-appropriate persistent storage and availability design.

## Proxy Access

The Teleport Proxy is exposed at:

```text
teleport.local:31546
```

The Mac maps:

```text
192.168.64.7 teleport.local
```

in `/etc/hosts`.

`publicAddr` is explicitly set to `teleport.local:31546` so Teleport clients follow the externally reachable NodePort rather than defaulting to 443.

## TLS and MFA

The standalone lab uses Teleport's self-signed certificate, so client commands use `--insecure`:

```bash
tsh login --proxy=teleport.local:31546 --user=ted --insecure
tsh kube login teleport-takehome --insecure
```

This is lab-only; production should use certificates trusted by clients.

WebAuthn was initially attempted, but the browser correctly rejected passkey enrollment because the self-signed certificate did not provide a trusted web origin. The lab therefore uses OTP MFA:

```yaml
authentication:
  secondFactors:
    - otp
```

## Least-Privilege Access

The final Teleport role maps the user to:

```text
teleport-app-deployers
```

That Kubernetes group is bound to the existing namespace-scoped `app-deployer` Role in `nginx-app`.

The final Teleport session showed:

```text
Roles:              app-deployer
Kubernetes groups:  teleport-app-deployers
```

Authorization through the Teleport-backed kube context was verified:

```text
list pods in nginx-app:  yes
list pods in default:    no
list nodes:              no
```

Actual API calls also confirmed:
- `kubectl get pods -n nginx-app` succeeds
- `kubectl get pods -n default` returns `Forbidden`
- `kubectl get nodes` returns `Forbidden`

## End-to-End Validation

```bash
tsh login --proxy=teleport.local:31546 --user=ted --insecure
tsh status
tsh kube ls
tsh kube login teleport-takehome --insecure
kubectl config current-context
kubectl get pods -n nginx-app
```

The resulting context is:

```text
teleport.local-teleport-takehome
```

## Native Kubernetes vs. Teleport

Mandatory native flow:

```text
private key
  -> CSR
  -> signed client certificate
  -> manually constructed kubeconfig
  -> Kubernetes RBAC
```

Optional Teleport flow:

```text
user + MFA
  -> Teleport
  -> short-lived identity
  -> Kubernetes group
  -> existing Kubernetes RBAC
```

Teleport does not replace Kubernetes RBAC here. It improves the identity, credential lifecycle, MFA, and access-brokering layer while Kubernetes continues to enforce workload authorization.

## Production Considerations

This optional integration favors simplicity for a small local lab. Production should reconsider self-signed TLS, `--insecure`, NodePort exposure, static local storage, single-replica standalone mode, local users rather than IdP integration, and backup/high-availability requirements.
