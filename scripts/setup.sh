#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/utils/common.sh"

# ============================================================
# SentinelAI - Platform Setup
# ============================================================

run_step() {

    local title="$1"
    local script="$2"

    echo
    echo "=================================================="
    log_info "${title}"
    echo "=================================================="
    echo

    if [[ ! -f "${script}" ]]; then
        die "Script not found: ${script}"
    fi

    bash "${script}"

}

main() {

    echo
    echo "##################################################"
    echo "#                                                #"
    echo "#         SentinelAI Platform Setup              #"
    echo "#                                                #"
    echo "##################################################"
    echo

    # ---------------------------------------------------------
    # Install Dependencies
    # ---------------------------------------------------------

    run_step \
        "Installing Docker..." \
        "${SCRIPT_DIR}/install/docker.sh"

    run_step \
        "Installing kubectl..." \
        "${SCRIPT_DIR}/install/kubectl.sh"

    run_step \
        "Installing Helm..." \
        "${SCRIPT_DIR}/install/helm.sh"

    run_step \
        "Installing k3d..." \
        "${SCRIPT_DIR}/install/k3d.sh"

    # ---------------------------------------------------------
    # Cluster
    # ---------------------------------------------------------

    run_step \
        "Detecting Cluster..." \
        "${SCRIPT_DIR}/cluster/detect.sh"

    run_step \
        "Creating Cluster..." \
        "${SCRIPT_DIR}/cluster/create.sh"

    run_step \
        "Exporting Kubeconfig..." \
        "${SCRIPT_DIR}/cluster/kubeconfig.sh"

    run_step \
        "Discovering Cluster..." \
        "${SCRIPT_DIR}/cluster/discover.sh"

    run_step \
        "Checking Cluster Network..." \
        "${SCRIPT_DIR}/cluster/network.sh"

    # ---------------------------------------------------------
    # Platform Deployment
    # ---------------------------------------------------------

    run_step \
        "Creating Namespaces..." \
        "${SCRIPT_DIR}/deploy/namespaces.sh"

    run_step \
        "Deploying Monitoring Stack..." \
        "${SCRIPT_DIR}/deploy/monitoring.sh"

    # ---------------------------------------------------------
    # Optional Components
    # ---------------------------------------------------------

    if [[ "${DEPLOY_ARGOCD:-false}" == "true" ]]; then

        run_step \
            "Deploying ArgoCD..." \
            "${SCRIPT_DIR}/deploy/argocd.sh"

    else

        log_warn "Skipping ArgoCD deployment."

    fi

    # ---------------------------------------------------------
    # Platform Health Check
    # ---------------------------------------------------------

    run_step \
        "Running Platform Doctor..." \
        "${SCRIPT_DIR}/health/doctor.sh"

    echo
    echo "##################################################"
    log_success "SentinelAI Platform setup completed successfully."
    echo "##################################################"
    echo

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
