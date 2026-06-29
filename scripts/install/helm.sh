#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils/common.sh"

install_helm() {

    log_info "Checking Helm..."

    if command_exists helm; then
        log_success "Helm already installed."
        return
    fi

    log_warn "Helm not found. Installing..."

    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    log_success "Helm installed successfully."

}

verify_helm() {

    log_info "Verifying Helm..."

    helm version >/dev/null

    log_success "$(helm version --short)"

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    install_helm

    verify_helm

fi
