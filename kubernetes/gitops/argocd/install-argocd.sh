#!/usr/bin/env bash
# Bootstrap ArgoCD into a Kubernetes cluster.
set -euo pipefail

NAMESPACE=argocd

echo ">> Creating namespace ${NAMESPACE}"
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

echo ">> Installing ArgoCD"
kubectl apply -n "${NAMESPACE}" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo ">> Waiting for ArgoCD server rollout"
kubectl rollout status deploy/argocd-server -n "${NAMESPACE}" --timeout=180s

echo ">> Initial admin password:"
kubectl -n "${NAMESPACE}" get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d; echo

echo ">> Done. Port-forward with:"
echo "   kubectl port-forward svc/argocd-server -n ${NAMESPACE} 8080:443"
