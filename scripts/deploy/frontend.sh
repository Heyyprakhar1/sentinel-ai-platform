#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

source "${SCRIPT_DIR}/../utils/common.sh"

log_info "Deploying SentinelAI Frontend..."

kubectl apply -k "${PROJECT_ROOT}/k8s/frontend"

kubectl rollout status \
    deployment/sentinelai-frontend \
    -n sentinelai-dev \
    --timeout=180s

echo
kubectl get pods -n sentinelai-dev

echo
kubectl get svc -n sentinelai-dev

log_success "Frontend deployed successfully."
