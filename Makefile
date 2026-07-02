SHELL := /usr/bin/env bash

.DEFAULT_GOAL := help

SCRIPTS := scripts
ENV ?= dev

.PHONY: \
	help \
	docker kubectl helm k3d install \
	detect create kubeconfig discover network cluster \
	backend frontend build \
	namespaces monitoring argocd \
	deploy deploy-backend deploy-frontend \
	doctor restart logs \
	clean teardown all

# ============================================================
# SentinelAI Platform
# ============================================================

help:
	@echo ""
	@echo "=================================================="
	@echo "             SentinelAI Platform"
	@echo "=================================================="
	@echo ""
	@echo "Installation"
	@echo "  make install"
	@echo ""
	@echo "Cluster"
	@echo "  make cluster"
	@echo ""
	@echo "Images"
	@echo "  make backend"
	@echo "  make frontend"
	@echo "  make build"
	@echo ""
	@echo "Deployment"
	@echo "  make deploy"
	@echo ""
	@echo "Operations"
	@echo "  make doctor"
	@echo "  make restart"
	@echo "  make logs"
	@echo ""
	@echo "Cleanup"
	@echo "  make clean"
	@echo "  make teardown"
	@echo ""
	@echo "Complete Platform"
	@echo "  make all"
	@echo ""

# ============================================================
# Installation
# ============================================================

docker:
	@bash $(SCRIPTS)/install/docker.sh

kubectl:
	@bash $(SCRIPTS)/install/kubectl.sh

helm:
	@bash $(SCRIPTS)/install/helm.sh

k3d:
	@bash $(SCRIPTS)/install/k3d.sh

install:
	@$(MAKE) --no-print-directory docker
	@$(MAKE) --no-print-directory kubectl
	@$(MAKE) --no-print-directory helm
	@$(MAKE) --no-print-directory k3d

# ============================================================
# Cluster
# ============================================================

detect:
	@bash $(SCRIPTS)/cluster/detect.sh

create:
	@bash $(SCRIPTS)/cluster/create.sh

kubeconfig:
	@bash $(SCRIPTS)/cluster/kubeconfig.sh

discover:
	@bash $(SCRIPTS)/cluster/discover.sh

network:
	@bash $(SCRIPTS)/cluster/network.sh

cluster:
	@$(MAKE) --no-print-directory detect
	@$(MAKE) --no-print-directory create
	@$(MAKE) --no-print-directory kubeconfig
	@$(MAKE) --no-print-directory discover
	@$(MAKE) --no-print-directory network

# ============================================================
# Build Images
# ============================================================

backend:
	@bash $(SCRIPTS)/build/backend.sh

frontend:
	@bash $(SCRIPTS)/build/frontend.sh

build:
	@$(MAKE) --no-print-directory backend
	@$(MAKE) --no-print-directory frontend

# ============================================================
# Deployment
# ============================================================

namespaces:
	@bash $(SCRIPTS)/deploy/namespaces.sh

monitoring:
	@bash $(SCRIPTS)/deploy/monitoring.sh

argocd:
	@bash $(SCRIPTS)/deploy/argocd.sh

deploy-backend:
	@bash $(SCRIPTS)/deploy/application.sh $(ENV)

deploy-frontend:
	@bash $(SCRIPTS)/deploy/frontend.sh

deploy:
	@$(MAKE) --no-print-directory namespaces
	@$(MAKE) --no-print-directory monitoring
	@$(MAKE) --no-print-directory deploy-backend
	@$(MAKE) --no-print-directory deploy-frontend

	@echo ""
	@echo "======================================="
	@echo "[OK] SentinelAI deployed successfully."
	@echo "======================================="

# ============================================================
# Health
# ============================================================

doctor:
	@bash $(SCRIPTS)/health/doctor.sh

# ============================================================
# Operations
# ============================================================

restart:
	@kubectl rollout restart deployment/dev-sentinelai -n sentinelai-dev
	@kubectl rollout restart deployment/sentinelai-frontend -n sentinelai-dev

logs:
	@kubectl logs -n sentinelai-dev deployment/dev-sentinelai -f

clean:
	@docker image prune -f

teardown:
	@bash $(SCRIPTS)/teardown.sh

# ============================================================
# Complete Platform Setup
# ============================================================

setup:
	@echo ""
	@echo "=================================================="
	@echo "        SentinelAI Platform Setup"
	@echo "=================================================="
	@echo ""

	@$(MAKE) --no-print-directory cluster

	@$(MAKE) --no-print-directory namespaces

	@$(MAKE) --no-print-directory monitoring

	@$(MAKE) --no-print-directory argocd

	@$(MAKE) --no-print-directory build

	@$(MAKE) --no-print-directory deploy

	@$(MAKE) --no-print-directory doctor

	@echo ""
	@echo "=================================================="
	@echo "             SentinelAI Platform Ready"
	@echo "=================================================="
	@echo ""

	@echo " Components"
	@echo " ----------"
	@echo "  ✓ Kubernetes Cluster"
	@echo "  ✓ Backend API"
	@echo "  ✓ Frontend Dashboard"
	@echo "  ✓ Prometheus"
	@echo "  ✓ Grafana"
	@echo "  ✓ ArgoCD"

	@echo ""
	@echo " Statistics"
	@echo " ----------"
	@printf "  Pods         : "
	@kubectl get pods -A --no-headers | wc -l

	@printf "  Namespaces   : "
	@kubectl get ns --no-headers | wc -l

	@printf "  Context      : "
	@kubectl config current-context

	@echo ""
	@echo "=================================================="
	@echo "        SentinelAI is Ready to Use 🚀"
	@echo "=================================================="
