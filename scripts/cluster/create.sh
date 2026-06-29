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

cluster_exists() {

    if ! command_exists k3d; then
        die "k3d is not installed."
    fi

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
        --api-port "${API_PORT}"

    log_success "Cluster created successfully."

}

wait_for_cluster() {

    log_info "Waiting for Kubernetes API..."

    local retries=30

    until kubectl get nodes >/dev/null 2>&1; do

        ((retries--))

        if [[ "${retries}" -le 0 ]]; then
            die "Cluster did not become ready."
        fi

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
