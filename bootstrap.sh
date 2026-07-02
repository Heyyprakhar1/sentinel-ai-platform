#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo
echo "=================================================="
echo "        SentinelAI Bootstrap"
echo "=================================================="
echo

###############################################
# Root Check
###############################################

if [[ $EUID -eq 0 ]]; then
    echo "[ERROR] Do not run bootstrap as root."
    exit 1
fi

###############################################
# Ubuntu Check
###############################################

if ! grep -qi ubuntu /etc/os-release; then
    echo "[ERROR] Only Ubuntu is currently supported."
    exit 1
fi

###############################################
# Update Packages
###############################################

echo "[INFO] Updating package index..."

sudo apt-get update -y

###############################################
# Basic Packages
###############################################

echo "[INFO] Installing base packages..."

sudo apt-get install -y \
curl \
git \
wget \
jq \
unzip \
make \
ca-certificates \
gnupg \
lsb-release

###############################################
# Docker
###############################################

echo
echo "[INFO] Installing Docker..."

make docker

###############################################
# Docker Compose
###############################################

echo
echo "[INFO] Installing Docker Compose..."

if docker compose version >/dev/null 2>&1
then
    echo "[OK] Docker Compose already installed."
else
    sudo apt-get install -y docker-compose-plugin
fi

###############################################
# kubectl
###############################################

echo
echo "[INFO] Installing kubectl..."

make kubectl

###############################################
# Helm
###############################################

echo
echo "[INFO] Installing Helm..."

make helm

###############################################
# k3d
###############################################

echo
echo "[INFO] Installing k3d..."

make k3d

###############################################
# Docker Group
###############################################

echo
echo "[INFO] Configuring Docker permissions..."

if groups "$USER" | grep -qw docker
then
    echo "[OK] User already belongs to docker group."
else
    sudo usermod -aG docker "$USER"
    echo "[OK] Added '$USER' to docker group."
fi

###############################################
# Refresh Group
###############################################

if docker ps >/dev/null 2>&1
then
    echo "[OK] Docker already accessible."
else
    echo
    echo "=================================================="
    echo "IMPORTANT"
    echo "=================================================="
    echo
    echo "Run:"
    echo
    echo "newgrp docker"
    echo
    echo "Then execute:"
    echo
    echo "make setup"
    echo
    exit 0
fi

###############################################
# Verification
###############################################

echo
echo "=================================================="
echo "Verification"
echo "=================================================="

docker --version

docker compose version

kubectl version --client

helm version --short

k3d version

make --version | head -1

echo
echo "=================================================="
echo "[OK] Bootstrap completed successfully."
echo
echo "Next step:"
echo
echo "make setup"
echo
echo "=================================================="
