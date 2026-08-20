#!/usr/bin/env bash
set -euo pipefail

CONTROL_PLANE_IP="${1:-192.168.64.5}"
POD_CIDR="${2:-192.168.0.0/16}"

echo "Initializing Kubernetes control plane"
echo "API server IP: ${CONTROL_PLANE_IP}"
echo "Pod CIDR:      ${POD_CIDR}"

sudo kubeadm init \
  --apiserver-advertise-address="${CONTROL_PLANE_IP}" \
  --pod-network-cidr="${POD_CIDR}"

mkdir -p "${HOME}/.kube"

sudo cp /etc/kubernetes/admin.conf "${HOME}/.kube/config"
sudo chown "$(id -u):$(id -g)" "${HOME}/.kube/config"

echo
echo "Control plane initialized."
echo
echo "Generate a worker join command with:"
echo
echo "  kubeadm token create --print-join-command"
