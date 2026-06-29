#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils/common.sh"

# ============================================================
# SentinelAI - k3d Installer
# ============================================================

install_k3d() {

    log_info "Checking k3d..."

    if command_exists k3d; then
        log_success "k3d already installed."
        return
    fi

    log_warn "k3d not found. Installing..."

    curl -fsSL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

    log_success "k3d installed successfully."

}

verify_k3d() {

    log_info "Verifying k3d..."

    if ! command_exists k3d; then
        die "k3d installation failed."
    fi

    log_success "$(k3d version)"

}

# Execute only when run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    install_k3d
    verify_k3d

fi
