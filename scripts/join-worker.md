# Joining Worker Nodes

Worker join tokens are intentionally not stored in this repository.

On the control-plane node, generate a fresh join command:

```bash
kubeadm token create --print-join-command
```

Example format:

```text
kubeadm join <CONTROL_PLANE_IP>:6443 \
  --token <BOOTSTRAP_TOKEN> \
  --discovery-token-ca-cert-hash sha256:<CA_HASH>
```

Run the generated command with `sudo` on each worker node.

After both workers have joined, verify from the control plane:

```bash
kubectl get nodes -o wide
```

Expected topology:

```text
k8s-control   Ready   control-plane
k8s-worker1   Ready   <none>
k8s-worker2   Ready   <none>
```

Bootstrap tokens and kubeconfigs must not be committed to source control.
