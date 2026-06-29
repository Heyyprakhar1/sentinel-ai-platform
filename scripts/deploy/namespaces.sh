#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/../utils/common.sh"
source "${SCRIPT_DIR}/../cluster/kubeconfig.sh"

# ============================================================
# SentinelAI - Namespace Deployment
# ============================================================

NAMESPACES=(
    argocd
    monitoring
    sentinelai-dev
    sentinelai-staging
    sentinelai-prod
)

namespace_exists() {

    local namespace="$1"

    kubectl get namespace "${namespace}" >/dev/null 2>&1

}

create_namespace() {

    local namespace="$1"

    if namespace_exists "${namespace}"; then
        log_success "Namespace '${namespace}' already exists."
        return
    fi

    log_info "Creating namespace '${namespace}'..."

    kubectl create namespace "${namespace}"

    log_success "Namespace '${namespace}' created."

}

create_all_namespaces() {

    export KUBECONFIG="${KUBECONFIG_FILE}"

    for namespace in "${NAMESPACES[@]}"; do
        create_namespace "${namespace}"
    done

}

verify_namespaces() {

    export KUBECONFIG="${KUBECONFIG_FILE}"

    log_info "Verifying namespaces..."

    kubectl get namespaces

    log_success "Namespace verification completed."

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    create_all_namespaces

    echo

    verify_namespaces

fi
