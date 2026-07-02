#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

source "${SCRIPT_DIR}/../utils/common.sh"

IMAGE_NAME="sentinelai"
IMAGE_TAG="1.0.0"
CLUSTER_NAME="Sentinel-Cluster"

log_info "Building SentinelAI backend image..."

docker build \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    "${PROJECT_ROOT}"

log_success "Backend image built."

log_info "Importing image into k3d..."

k3d image import \
    "${IMAGE_NAME}:${IMAGE_TAG}" \
    -c "${CLUSTER_NAME}"

log_success "Backend image imported."
