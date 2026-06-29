#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

source "${SCRIPT_DIR}/../utils/common.sh"

# ============================================================
# SentinelAI - Kubeconfig Management
# ============================================================

CLUSTER_NAME="${CLUSTER_NAME:-Sentinel-Cluster}"
KUBECONFIG_FILE="${PROJECT_ROOT}/k3d-kubeconfig.yaml"

export_kubeconfig() {

    if ! command_exists k3d; then
        die "k3d is not installed."
    fi

    log_info "Exporting kubeconfig..."

    local source_file

    source_file="$(k3d kubeconfig write "${CLUSTER_NAME}")"

    cp "${source_file}" "${KUBECONFIG_FILE}"

    log_success "Kubeconfig exported."

}

verify_kubeconfig() {

    if [[ ! -f "${KUBECONFIG_FILE}" ]]; then
        die "Kubeconfig file not found."
    fi

    KUBECONFIG="${KUBECONFIG_FILE}" \
        kubectl config current-context >/dev/null

    log_success "Kubeconfig verified."

}

show_current_context() {

    KUBECONFIG="${KUBECONFIG_FILE}" \
        kubectl config current-context

}

show_cluster() {

    KUBECONFIG="${KUBECONFIG_FILE}" \
        kubectl cluster-info

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    export_kubeconfig

    verify_kubeconfig

    echo

    log_info "Current Context:"
    show_current_context

    echo

    log_info "Cluster Information:"
    show_cluster

fi
