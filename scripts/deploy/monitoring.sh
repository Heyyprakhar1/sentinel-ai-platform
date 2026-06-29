#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

source "${SCRIPT_DIR}/../utils/common.sh"
source "${SCRIPT_DIR}/../cluster/kubeconfig.sh"

# ============================================================
# SentinelAI - Monitoring Stack Deployment
# ============================================================

NAMESPACE="monitoring"

RELEASE_NAME="sentinel-monitoring"

CHART="prometheus-community/kube-prometheus-stack"

VALUES_FILE="${PROJECT_ROOT}/monitoring/kubernetes/kube-prometheus-stack.values.yaml"

add_helm_repository() {

    log_info "Adding Prometheus Helm repository..."

    helm repo add prometheus-community \
        https://prometheus-community.github.io/helm-charts >/dev/null 2>&1

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

deploy_monitoring() {

    if release_exists; then
        log_success "Monitoring stack already installed."
        return
    fi

    if ! kubectl \
        --kubeconfig "${KUBECONFIG_FILE}" \
        get namespace "${NAMESPACE}" >/dev/null 2>&1; then

        die "Namespace '${NAMESPACE}' does not exist. Run namespaces.sh first."

    fi

    if [[ ! -f "${VALUES_FILE}" ]]; then
        die "Monitoring values file not found: ${VALUES_FILE}"
    fi

    local existing

    existing="$(existing_release)"

    if [[ -n "${existing}" && "${existing}" != "${RELEASE_NAME}" ]]; then

        die "Another monitoring release already exists: ${existing}"

    fi

    log_info "Deploying monitoring stack..."

    helm \
        --kubeconfig "${KUBECONFIG_FILE}" \
        install "${RELEASE_NAME}" \
        "${CHART}" \
        --namespace "${NAMESPACE}" \
        --values "${VALUES_FILE}" \
        --wait \
        --timeout 10m >/dev/null

    log_success "Monitoring stack deployed."

}

verify_monitoring() {

    log_info "Monitoring pods status..."

    kubectl \
        --kubeconfig "${KUBECONFIG_FILE}" \
        get pods \
        --namespace "${NAMESPACE}"

    log_success "Monitoring verification completed."

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    add_helm_repository

    deploy_monitoring

    echo

    verify_monitoring

fi
