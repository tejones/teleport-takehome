#!/usr/bin/env bash
set -euo pipefail

USER_NAME="${1:-app-deployer}"
USER_GROUP="${2:-app-deployers}"
EXPIRATION_SECONDS="${3:-86400}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CREDENTIALS_DIR="${REPO_ROOT}/credentials"
RBAC_DIR="${REPO_ROOT}/kubernetes/rbac"

mkdir -p "${CREDENTIALS_DIR}" "${RBAC_DIR}"

KEY_FILE="${CREDENTIALS_DIR}/${USER_NAME}.key"
CSR_FILE="${CREDENTIALS_DIR}/${USER_NAME}.csr"
MANIFEST_FILE="${RBAC_DIR}/${USER_NAME}-csr.yaml"

if [[ -e "${KEY_FILE}" || -e "${CSR_FILE}" ]]; then
  echo "Refusing to overwrite existing credentials for ${USER_NAME}." >&2
  echo "Remove or archive ${KEY_FILE} and ${CSR_FILE}, then retry." >&2
  exit 1
fi

openssl genrsa -out "${KEY_FILE}" 2048
openssl req -new \
  -key "${KEY_FILE}" \
  -out "${CSR_FILE}" \
  -subj "/CN=${USER_NAME}/O=${USER_GROUP}"

CSR_B64="$(base64 < "${CSR_FILE}" | tr -d '\n')"

cat > "${MANIFEST_FILE}" <<EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${USER_NAME}
spec:
  request: ${CSR_B64}
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: ${EXPIRATION_SECONDS}
  usages:
    - client auth
EOF

chmod 600 "${KEY_FILE}"

printf 'Generated:\n  private key: %s\n  CSR:         %s\n  manifest:    %s\n' \
  "${KEY_FILE}" "${CSR_FILE}" "${MANIFEST_FILE}"
printf '\nNext steps (administrator):\n'
printf '  kubectl apply -f %s\n' "${MANIFEST_FILE}"
printf '  kubectl certificate approve %s\n' "${USER_NAME}"
printf '\nPrivate key and raw CSR remain under credentials/ and must not be committed.\n'
