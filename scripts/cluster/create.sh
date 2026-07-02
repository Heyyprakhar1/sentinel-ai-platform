#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils/common.sh"

# ============================================================
# SentinelAI - Cluster Creation
# ============================================================

CLUSTER_NAME="${CLUSTER_NAME:-Sentinel-Cluster}"
AGENTS="${AGENTS:-2}"
API_PORT="${API_PORT:-6445}"

HTTP_PORT="${HTTP_PORT:-80}"
HTTPS_PORT="${HTTPS_PORT:-443}"

cluster_exists() {

    command_exists k3d || die "k3d is not installed."

    k3d cluster list | awk '{print $1}' | grep -Fxq "${CLUSTER_NAME}"

}

create_cluster() {

    if cluster_exists; then
        log_success "Cluster '${CLUSTER_NAME}' already exists."
        return
    fi

    log_info "Creating k3d cluster '${CLUSTER_NAME}'..."

    k3d cluster create "${CLUSTER_NAME}" \
        --agents "${AGENTS}" \
        --api-port "${API_PORT}" \
        --port "${HTTP_PORT}:80@loadbalancer" \
        --port "${HTTPS_PORT}:443@loadbalancer"

    log_success "Cluster created successfully."

}

wait_for_cluster() {

    log_info "Waiting for Kubernetes API..."

    local retries=30

    until kubectl get nodes >/dev/null 2>&1; do

        ((retries--))

        [[ "${retries}" -le 0 ]] && die "Cluster did not become ready."

        sleep 2

    done

    log_success "Cluster is ready."

}

verify_cluster() {

    log_info "Verifying cluster..."

    kubectl cluster-info >/dev/null

    kubectl get nodes

    log_success "Cluster verification completed."

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    create_cluster

fi
