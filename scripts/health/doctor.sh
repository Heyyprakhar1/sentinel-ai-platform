#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/../utils/common.sh"
source "${SCRIPT_DIR}/../cluster/kubeconfig.sh"

# ============================================================
# SentinelAI - Platform Doctor
# ============================================================

CLUSTER_NAME="${CLUSTER_NAME:-Sentinel-Cluster}"

MONITORING_NAMESPACE="monitoring"
MONITORING_RELEASE="sentinel-monitoring"

ARGOCD_NAMESPACE="argocd"
ARGOCD_RELEASE="sentinel-argocd"

print_header() {

    echo
    echo "=================================================="
    echo "          SentinelAI Platform Doctor"
    echo "=================================================="
    echo

}

check_binary() {

    local binary="$1"

    if command_exists "${binary}"; then
        log_success "${binary} installed."
    else
        log_error "${binary} not installed."
    fi

}

check_cluster() {

    if k3d cluster list | awk '{print $1}' | grep -Fxq "${CLUSTER_NAME}"; then
        log_success "Cluster '${CLUSTER_NAME}' found."
    else
        log_error "Cluster '${CLUSTER_NAME}' not found."
    fi

}

check_kubeconfig() {

    if [[ -f "${KUBECONFIG_FILE}" ]]; then
        log_success "Kubeconfig available."
    else
        log_error "Kubeconfig not found."
    fi

}

check_kubernetes_api() {

    if kubectl \
        --kubeconfig "${KUBECONFIG_FILE}" \
        cluster-info >/dev/null 2>&1; then

        log_success "Kubernetes API reachable."

    else

        log_error "Unable to reach Kubernetes API."

    fi

}

show_nodes() {

    echo
    log_info "Cluster Nodes"

    kubectl \
        --kubeconfig "${KUBECONFIG_FILE}" \
        get nodes \
        || log_warn "Unable to fetch cluster nodes."

}

check_namespace() {

    local namespace="$1"

    if kubectl \
        --kubeconfig "${KUBECONFIG_FILE}" \
        get namespace "${namespace}" >/dev/null 2>&1; then

        log_success "Namespace '${namespace}' exists."

    else

        log_warn "Namespace '${namespace}' not found."

    fi

}

check_release() {

    local namespace="$1"
    local release="$2"
    local title="$3"

    if helm \
        --kubeconfig "${KUBECONFIG_FILE}" \
        status "${release}" \
        --namespace "${namespace}" >/dev/null 2>&1; then

        log_success "${title} installed."

    else

        log_warn "${title} not installed."

    fi

}

main() {

    print_header

    log_info "Checking dependencies..."

    check_binary docker
    check_binary kubectl
    check_binary helm
    check_binary k3d

    echo

    log_info "Checking cluster..."

    check_cluster
    check_kubeconfig
    check_kubernetes_api

    show_nodes

    echo

    log_info "Checking namespaces..."

    check_namespace "${MONITORING_NAMESPACE}"
    check_namespace "${ARGOCD_NAMESPACE}"

    echo

    log_info "Checking platform components..."

    check_release \
        "${MONITORING_NAMESPACE}" \
        "${MONITORING_RELEASE}" \
        "Monitoring"

    check_release \
        "${ARGOCD_NAMESPACE}" \
        "${ARGOCD_RELEASE}" \
        "ArgoCD"

    echo

    log_success "Platform diagnosis completed."

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
