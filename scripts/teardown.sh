#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/utils/common.sh"
source "${SCRIPT_DIR}/cluster/kubeconfig.sh"

# ============================================================
# SentinelAI - Platform Teardown
# ============================================================

CLUSTER_NAME="${CLUSTER_NAME:-Sentinel-Cluster}"

MONITORING_NAMESPACE="monitoring"
MONITORING_RELEASE="sentinel-monitoring"

ARGOCD_NAMESPACE="argocd"
ARGOCD_RELEASE="sentinel-argocd"

remove_release() {

    local namespace="$1"
    local release="$2"
    local title="$3"

    if helm \
        --kubeconfig "${KUBECONFIG_FILE}" \
        status "${release}" \
        --namespace "${namespace}" >/dev/null 2>&1; then

        log_info "Removing ${title}..."

        helm \
            --kubeconfig "${KUBECONFIG_FILE}" \
            uninstall "${release}" \
            --namespace "${namespace}"

        log_success "${title} removed."

    else

        log_warn "${title} not installed."

    fi

}

delete_namespace() {

    local namespace="$1"

    if kubectl \
        --kubeconfig "${KUBECONFIG_FILE}" \
        get namespace "${namespace}" >/dev/null 2>&1; then

        log_info "Deleting namespace '${namespace}'..."

        kubectl \
            --kubeconfig "${KUBECONFIG_FILE}" \
            delete namespace "${namespace}" \
            --wait=true

        log_success "Namespace '${namespace}' deleted."

    else

        log_warn "Namespace '${namespace}' does not exist."

    fi

}

delete_cluster() {

    if k3d cluster list | awk '{print $1}' | grep -Fxq "${CLUSTER_NAME}"; then

        log_info "Deleting k3d cluster..."

        k3d cluster delete "${CLUSTER_NAME}"

        log_success "Cluster deleted."

    else

        log_warn "Cluster '${CLUSTER_NAME}' not found."

    fi

}

remove_kubeconfig() {

    if [[ -f "${KUBECONFIG_FILE}" ]]; then

        log_info "Removing kubeconfig..."

        rm -f "${KUBECONFIG_FILE}"

        log_success "Kubeconfig removed."

    else

        log_warn "Kubeconfig not found."

    fi

}

main() {

    echo
    echo "=================================================="
    echo "           SentinelAI Platform Teardown"
    echo "=================================================="
    echo

    remove_release \
        "${ARGOCD_NAMESPACE}" \
        "${ARGOCD_RELEASE}" \
        "ArgoCD"

    remove_release \
        "${MONITORING_NAMESPACE}" \
        "${MONITORING_RELEASE}" \
        "Monitoring"

    echo

    delete_namespace "${ARGOCD_NAMESPACE}"
    delete_namespace "${MONITORING_NAMESPACE}"

    echo

    delete_cluster

    echo

    remove_kubeconfig

    echo

    log_success "Platform teardown completed."

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
