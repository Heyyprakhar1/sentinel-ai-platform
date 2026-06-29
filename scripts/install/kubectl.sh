#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils/common.sh"

install_kubectl() {

    log_info "Checking kubectl..."

    if command_exists kubectl; then
        log_success "kubectl already installed."
        return
    fi

    log_warn "kubectl not found. Installing..."

    sudo apt-get update -y

    sudo apt-get install -y apt-transport-https ca-certificates curl gpg

    sudo mkdir -p /etc/apt/keyrings

    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key \
        | sudo gpg --dearmor \
        -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    echo \
"deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" \
| sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null

    sudo apt-get update -y

    sudo apt-get install -y kubectl

    log_success "kubectl installed successfully."

}

verify_kubectl() {

    log_info "Verifying kubectl..."

    kubectl version --client >/dev/null

    log_success "$(kubectl version --client --short 2>/dev/null || kubectl version --client)"

}

main() {

    install_kubectl

    verify_kubectl

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
