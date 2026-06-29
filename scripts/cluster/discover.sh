#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils/common.sh"

# ============================================================
# SentinelAI - Cluster Discovery
# ============================================================

CLUSTER_NAME="${CLUSTER_NAME:-Sentinel-Cluster}"

get_cluster_name() {

    echo "${CLUSTER_NAME}"

}

get_server_container() {

    docker ps \
        --format "{{.Names}}" \
        | grep "^k3d-${CLUSTER_NAME}-server-0$" \
        || true

}

get_backend_container() {
	
	docker ps \
		--format "{{.Names}}" \
		| grep "^sentinelai-backend$" \
		|| true 

}

get_network_name() {

    docker network ls \
        --format "{{.Name}}" \
        | grep "^k3d-${CLUSTER_NAME}$" \
        || true

}

cluster_exists() {

    k3d cluster list \
        | awk '{print $1}' \
        | grep -Fxq "${CLUSTER_NAME}"

}

show_discovery() {

    echo
    echo "==========================================="
    echo " SentinelAI Cluster Discovery"
    echo "==========================================="
    echo

    printf "%-20s : %s\n" \
        "Cluster Name" \
        "$(get_cluster_name)"

    printf "%-20s : %s\n" \
        "Docker Network" \
        "$(get_network_name)"

    printf "%-20s : %s\n" \
        "Server Container" \
        "$(get_server_container)"

    if cluster_exists; then
        printf "%-20s : %s\n" "Cluster Exists" "Yes"
    else
        printf "%-20s : %s\n" "Cluster Exists" "No"
    fi

    echo
    echo "==========================================="

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    show_discovery

fi
