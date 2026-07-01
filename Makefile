SHELL := /usr/bin/env bash

.DEFAULT_GOAL := help

SCRIPTS := scripts

ENV ?= dev

.PHONY: \
        help \
        docker \
        kubectl \
        helm \
        deploy \
        k3d \
        install \
        detect \
        create \
        kubeconfig \
        discover \
        network \
        cluster \
        namespaces \
        monitoring \
        argocd \
        doctor \
        setup \
        teardown

# ============================================================
# SentinelAI Platform
# ============================================================

help:
	@echo ""
	@echo "=================================================="
	@echo "            SentinelAI Platform"
	@echo "=================================================="
	@echo ""
	@echo "Available Commands"
	@echo ""
	@echo "Installation"
	@echo "  make docker        Install Docker"
	@echo "  make kubectl       Install kubectl"
	@echo "  make helm          Install Helm"
	@echo "  make k3d           Install k3d"
	@echo "  make install       Install all dependencies"
	@echo ""
	@echo "Cluster"
	@echo "  make detect        Detect environment"
	@echo "  make create        Create Kubernetes cluster"
	@echo "  make kubeconfig    Export kubeconfig"
	@echo "  make discover      Discover cluster"
	@echo "  make network       Configure Docker network"
	@echo "  make cluster       Complete cluster setup"
	@echo ""
	@echo "Deployment"
	@echo "  make namespaces    Create namespaces"
	@echo "  make deploy        Deploy platform components"
	@echo "  make monitoring    Deploy monitoring stack"
	@echo "  make argocd        Deploy ArgoCD"
	@echo ""
	@echo "Health"
	@echo "  make doctor        Run platform diagnostics"
	@echo ""
	@echo "Platform"
	@echo "  make setup         Complete platform setup"
	@echo "  make teardown      Remove complete platform"
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
# Deployment
# ============================================================

namespaces:
	@bash $(SCRIPTS)/deploy/namespaces.sh

monitoring:
	@bash $(SCRIPTS)/deploy/monitoring.sh

argocd:
	@bash $(SCRIPTS)/deploy/argocd.sh

deploy:
	@$(MAKE) --no-print-directory namespaces
	@$(MAKE) --no-print-directory monitoring
	@bash $(SCRIPTS)/deploy/application.sh $(ENV)
	@echo ""
	@echo "[OK] Deployment completed."

# ============================================================
# Health
# ============================================================

doctor:
	@bash $(SCRIPTS)/health/doctor.sh
