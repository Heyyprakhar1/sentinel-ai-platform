#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/../utils/common.sh"
source "${SCRIPT_DIR}/discover.sh"

# ============================================================
# SentinelAI - Docker Network Management
# ============================================================

backend_container_exists() {

    docker inspect "$(get_backend_container)" >/dev/null 2>&1

}

container_connected() {

    docker inspect \
        -f '{{json .NetworkSettings.Networks}}' \
        "$(get_backend_container)" \
        | grep -q "\"$(get_network_name)\""

}

connect_backend_network() {

    local network
    local backend

    network="$(get_network_name)"
    backend="$(get_backend_container)"

    [[ -z "${network}" ]] && die "Docker network not found."

    if [[ -z "${backend}" ]]; then
        log_info "Docker Compose backend not found. Skipping network configuration."
        return 0
    fi

    if container_connected; then
        log_success "Backend already connected to '${network}'."
        return
    fi

    log_info "Connecting backend to '${network}'..."

    docker network connect "${network}" "${backend}"

    log_success "Backend connected successfully."

}

disconnect_backend_network() {

    local network
    local backend

    network="$(get_network_name)"
    backend="$(get_backend_container)"

    [[ -z "${network}" ]] && {
        log_warn "Docker network not found."
        return
    }

    [[ -z "${backend}" ]] && {
        log_warn "Backend container not found."
        return
    }

    if ! container_connected; then
        log_success "Backend already disconnected."
        return
    fi

    log_info "Disconnecting backend..."

    docker network disconnect "${network}" "${backend}"

    log_success "Backend disconnected."

}

verify_network() {

    if ! backend_container_exists; then
        log_info "Docker Compose backend not running. Network verification skipped."
        return 0
    fi

    if container_connected; then
        log_success "Backend is connected to '$(get_network_name)'."
    else
        die "Backend is NOT connected to Docker network."
    fi

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    connect_backend_network

    verify_network

    echo
    log_success "Docker network checks completed."

fi
