#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

source "${SCRIPT_DIR}/../utils/common.sh"

ENVIRONMENT="${1:-dev}"

IMAGE_NAME="sentinelai"
IMAGE_TAG="1.0.0"

CLUSTER_NAME="Sentinel-Cluster"

OVERLAY_DIR="${PROJECT_ROOT}/k8s/overlays/${ENVIRONMENT}"
NAMESPACE="sentinelai-${ENVIRONMENT}"

# ============================================================
# Validate Environment
# ============================================================

validate_environment() {

    case "${ENVIRONMENT}" in
        dev|staging|prod)
            ;;
        *)
            die "Invalid environment '${ENVIRONMENT}'. Use dev, staging or prod."
            ;;
    esac

}

# ============================================================
# Validate Cluster
# ============================================================

validate_cluster() {

    log_info "Checking Kubernetes cluster..."

    kubectl cluster-info >/dev/null 2>&1 \
        || die "Kubernetes cluster is not available."

    log_success "Cluster is available."

}

# ============================================================
# Validate Overlay
# ============================================================

validate_overlay() {

    [[ -d "${OVERLAY_DIR}" ]] \
        || die "Overlay '${OVERLAY_DIR}' not found."

    log_success "Overlay found."

}

# ============================================================
# Build Docker Image
# ============================================================

build_image() {

    log_info "Building Docker image..."

    docker build \
        -t "${IMAGE_NAME}:${IMAGE_TAG}" \
        "${PROJECT_ROOT}"

    log_success "Docker image built."

}

# ============================================================
# Import Image into k3d
# ============================================================

import_image() {

    log_info "Importing image into k3d..."

    k3d image import \
        "${IMAGE_NAME}:${IMAGE_TAG}" \
        -c "${CLUSTER_NAME}"

    log_success "Image imported."

}

# ============================================================
# Deploy Application
# ============================================================

deploy_application() {

    log_info "Deploying SentinelAI (${ENVIRONMENT})..."

    kubectl apply -k "${OVERLAY_DIR}"

    log_success "Resources applied."

}

# ============================================================
# Verify Deployment
# ============================================================

verify_application() {

    log_info "Waiting for deployment..."

    DEPLOYMENT_NAME=$(
    	kubectl get deployment \
        	-n "${NAMESPACE}" \
        	-o jsonpath='{.items[0].metadata.name}'
)

  [[ -z "${DEPLOYMENT_NAME}" ]] && \
    	die "No deployment found in namespace '${NAMESPACE}'."

  log_info "Waiting for deployment '${DEPLOYMENT_NAME}'..."

  kubectl rollout status \
    	deployment/"${DEPLOYMENT_NAME}" \
    	-n "${NAMESPACE}" \
    	--timeout=180s

    echo
    kubectl get pods -n "${NAMESPACE}"

    echo
    kubectl get svc -n "${NAMESPACE}"

    log_success "Application deployed successfully."

}

main() {

    validate_environment

    validate_cluster

    validate_overlay

    build_image

    import_image

    deploy_application

    verify_application

}

main
