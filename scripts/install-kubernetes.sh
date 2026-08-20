#!/usr/bin/env bash
set -euo pipefail

KUBERNETES_VERSION="1.35.7-1.1"

echo "[1/5] Installing containerd"
sudo apt-get update
sudo apt-get install -y containerd

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

sudo sed -i \
  's/SystemdCgroup = false/SystemdCgroup = true/' \
  /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

echo "[2/5] Installing Kubernetes repository prerequisites"
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gpg

sudo mkdir -p -m 755 /etc/apt/keyrings

curl -fsSL \
  https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key \
  | sudo gpg --dearmor \
  -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "[3/5] Installing Kubernetes ${KUBERNETES_VERSION}"
sudo apt-get update

sudo apt-get install -y \
  kubelet="${KUBERNETES_VERSION}" \
  kubeadm="${KUBERNETES_VERSION}" \
  kubectl="${KUBERNETES_VERSION}"

echo "[4/5] Holding Kubernetes package versions"
sudo apt-mark hold kubelet kubeadm kubectl

echo "[5/5] Verifying installation"
containerd --version
kubeadm version -o short
kubectl version --client
kubelet --version

echo "Kubernetes installation complete."
