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

    command_exists k3d || die "k3d is not installed."

    log_info "Exporting kubeconfig..."

    local source_file
    source_file="$(k3d kubeconfig write "${CLUSTER_NAME}")"

    [[ -f "${source_file}" ]] \
        || die "k3d kubeconfig not found: ${source_file}"

    cp "${source_file}" "${KUBECONFIG_FILE}"

    [[ -f "${KUBECONFIG_FILE}" ]] \
        || die "Failed to create ${KUBECONFIG_FILE}"

    log_success "Kubeconfig exported."

    log_info "Saved to: ${KUBECONFIG_FILE}"

}

ensure_kubeconfig() {

    if [[ ! -f "${KUBECONFIG_FILE}" ]]; then
        export_kubeconfig
    fi

}

verify_kubeconfig() {

    ensure_kubeconfig

    kubectl \
        --kubeconfig "${KUBECONFIG_FILE}" \
        config current-context >/dev/null

    log_success "Kubeconfig verified."

}

show_current_context() {

    kubectl \
        --kubeconfig "${KUBECONFIG_FILE}" \
        config current-context

}

show_cluster() {

    kubectl \
        --kubeconfig "${KUBECONFIG_FILE}" \
        cluster-info

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    ensure_kubeconfig

    verify_kubeconfig

    echo

    log_info "Current Context:"
    show_current_context

    echo

    log_info "Cluster Information:"
    show_cluster

fi
