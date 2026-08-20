#!/usr/bin/env bash
set -euo pipefail

CALICO_VERSION="v3.32.1"
CERT_MANAGER_VERSION="v1.21.1"
INGRESS_NGINX_VERSION="controller-v1.15.1"

echo "[1/3] Installing Calico"
kubectl apply -f \
  "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/calico.yaml"

echo "[2/3] Installing cert-manager"
kubectl apply -f \
  "https://github.com/cert-manager/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.yaml"

echo "[3/3] Installing ingress-nginx"
kubectl apply -f \
  "https://raw.githubusercontent.com/kubernetes/ingress-nginx/${INGRESS_NGINX_VERSION}/deploy/static/provider/baremetal/deploy.yaml"

echo
echo "Waiting briefly before showing component status..."
sleep 10

kubectl get nodes
kubectl get pods -n kube-system
kubectl get pods -n cert-manager
kubectl get pods -n ingress-nginx

echo
echo "Platform component installation submitted."
echo "Wait for all required pods to become Ready before continuing."
