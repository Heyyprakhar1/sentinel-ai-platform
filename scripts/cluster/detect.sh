#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils/common.sh"

# ============================================================
# SentinelAI - Environment Detection
# ============================================================

detect_os() {

    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "${PRETTY_NAME}"
    else
        uname -s
    fi

}

detect_environment() {

    if curl -fs --connect-timeout 2 \
        http://169.254.169.254/latest/meta-data/ >/dev/null 2>&1; then
        echo "AWS EC2"
    else
        echo "Local Machine"
    fi

}

detect_docker() {

    if command_exists docker; then
        echo "Installed"
    else
        echo "Not Installed"
    fi

}

detect_kubectl() {

    if command_exists kubectl; then
        echo "Installed"
    else
        echo "Not Installed"
    fi

}

detect_helm() {

    if command_exists helm; then
        echo "Installed"
    else
        echo "Not Installed"
    fi

}

detect_k3d() {

    if command_exists k3d; then
        echo "Installed"
    else
        echo "Not Installed"
    fi

}

detect_cluster() {

    if ! command_exists kubectl; then
        echo "Unavailable"
        return
    fi

    if kubectl get nodes >/dev/null 2>&1; then
        echo "Running"
    else
        echo "Not Running"
    fi

}

run_detection() {

    echo
    echo "==========================================="
    echo " SentinelAI Environment Detection"
    echo "==========================================="
    echo

    printf "%-18s : %s\n" "Operating System" "$(detect_os)"
    printf "%-18s : %s\n" "Environment"      "$(detect_environment)"
    printf "%-18s : %s\n" "Docker"           "$(detect_docker)"
    printf "%-18s : %s\n" "Kubectl"          "$(detect_kubectl)"
    printf "%-18s : %s\n" "Helm"             "$(detect_helm)"
    printf "%-18s : %s\n" "k3d"              "$(detect_k3d)"
    printf "%-18s : %s\n" "Cluster"          "$(detect_cluster)"

    echo
    echo "==========================================="

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    run_detection

fi
