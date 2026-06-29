#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

source "${SCRIPT_DIR}/../utils/common.sh"
source "${SCRIPT_DIR}/../cluster/kubeconfig.sh"

# ============================================================
# SentinelAI - ArgoCD Deployment
# ============================================================

NAMESPACE="argocd"

RELEASE_NAME="sentinel-argocd"

CHART="argo/argo-cd"

VALUES_FILE="${PROJECT_ROOT}/argocd/helm/values.yaml"

add_helm_repository() {

    log_info "Adding ArgoCD Helm repository..."

    helm repo add argo \
        https://argoproj.github.io/argo-helm >/dev/null 2>&1

    helm repo update >/dev/null 2>&1

    log_success "Helm repository updated."

}

release_exists() {

    helm \
        --kubeconfig "${KUBECONFIG_FILE}" \
        status "${RELEASE_NAME}" \
        --namespace "${NAMESPACE}" >/dev/null 2>&1

}

existing_release() {

    helm \
        --kubeconfig "${KUBECONFIG_FILE}" \
        list \
        --namespace "${NAMESPACE}" \
        --short

}

deploy_argocd() {

    if release_exists; then
        log_success "ArgoCD already installed."
        return
    fi

    if ! kubectl \
        --kubeconfig "${KUBECONFIG_FILE}" \
        get namespace "${NAMESPACE}" >/dev/null 2>&1; then

        die "Namespace '${NAMESPACE}' does not exist. Run namespaces.sh first."

    fi

    if [[ ! -f "${VALUES_FILE}" ]]; then
        die "ArgoCD values file not found: ${VALUES_FILE}"
    fi

    local existing

    existing="$(existing_release)"

    if [[ -n "${existing}" && "${existing}" != "${RELEASE_NAME}" ]]; then
        die "Another ArgoCD release already exists: ${existing}"
    fi

    log_info "Deploying ArgoCD..."

    helm \
        --kubeconfig "${KUBECONFIG_FILE}" \
        install "${RELEASE_NAME}" \
        "${CHART}" \
        --namespace "${NAMESPACE}" \
        --values "${VALUES_FILE}" \
        --wait \
        --timeout 10m >/dev/null

    log_success "ArgoCD deployed."

}

verify_argocd() {

    log_info "ArgoCD pods status..."

    kubectl \
        --kubeconfig "${KUBECONFIG_FILE}" \
        get pods \
        --namespace "${NAMESPACE}"

    log_success "ArgoCD verification completed."

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    add_helm_repository

    deploy_argocd

    echo

    verify_argocd

fi
