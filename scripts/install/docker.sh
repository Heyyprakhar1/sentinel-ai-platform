#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils/common.sh"

install_docker() {

    log_info "Checking Docker..."

    if command_exists docker; then
        log_success "Docker already installed."
        return
    fi

    log_warn "Docker not found. Installing..."

    curl -fsSL https://get.docker.com | sh

    sudo usermod -aG docker "$USER"

    log_success "Docker installed successfully."

}

verify_docker() {

    log_info "Verifying Docker installation..."

    docker --version >/dev/null

    log_success "$(docker --version)"

}

main() {
	install_docker	

	verify_docker

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
