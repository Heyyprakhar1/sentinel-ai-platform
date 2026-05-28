#!/bin/bash

# ── Colors ─────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC}  $1"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo -e "${CYAN}"
echo "╔══════════════════════════════════════╗"
echo "║     SentinelAI — K3d Cluster Setup   ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}"

# ── Cluster name ───────────────────────────────────────────────────
read -p "Enter cluster name [k3d-Sentinel-Cluster]: " CLUSTER_NAME
CLUSTER_NAME=${CLUSTER_NAME:-k3d-Sentinel-Cluster}
info "Cluster name set to: $CLUSTER_NAME"

# ── Cleanup old installs ───────────────────────────────────────────
cleanup() {
  info "Removing old Docker installations..."
  sudo apt-get remove -y docker docker-engine docker.io containerd runc docker-compose 2>/dev/null || true
  sudo apt-get autoremove -y 2>/dev/null || true
  ok "Old Docker removed."
}

# ── Install make ───────────────────────────────────────────────────
install_make() {
  info "Installing make..."
  sudo apt-get install -y make
  ok "make installed: $(make --version | head -1)"
}

# ── Install Docker + Compose plugin (official repo) ────────────────
install_docker() {
  info "Installing Docker from official repo..."
  sudo apt-get update -qq
  sudo apt-get install -y ca-certificates curl gnupg

  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update -qq
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker $USER
  newgrp docker
  ok "Docker installed: $(docker --version)"
  ok "Docker Compose installed: $(docker compose version)"
}

# ── Install kubectl ────────────────────────────────────────────────
install_kubectl() {
  info "Installing kubectl..."
  sudo rm -f /usr/local/bin/kubectl
  curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  ok "kubectl installed: $(kubectl version --client --short 2>/dev/null)"
}

# ── Install k3d ────────────────────────────────────────────────────
install_k3d() {
  info "Installing k3d..."
  sudo rm -f /usr/local/bin/k3d
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
  ok "k3d installed: $(k3d version | head -1)"
}

# ── Check + auto-install ───────────────────────────────────────────
info "Checking prerequisites..."
sudo apt-get update -qq

if ! command -v make &> /dev/null; then
  warn "make not found. Installing..."
  install_make
else
  ok "make found: $(make --version | head -1)"
fi

# Docker — cleanup old, install fresh from official repo
if ! docker compose version &> /dev/null 2>&1; then
  warn "Docker or Compose plugin not found. Cleaning up and reinstalling..."
  cleanup
  install_docker
else
  ok "Docker found: $(docker --version)"
  ok "Docker Compose found: $(docker compose version)"
  if ! groups $USER | grep -q docker; then
    warn "User not in docker group. Fixing..."
    sudo usermod -aG docker $USER
    newgrp docker
    ok "User added to docker group."
  fi
fi

if ! command -v kubectl &> /dev/null; then
  warn "kubectl not found. Installing..."
  install_kubectl
else
  ok "kubectl found: $(kubectl version --client --short 2>/dev/null)"
fi

if ! command -v k3d &> /dev/null; then
  warn "k3d not found. Installing..."
  install_k3d
else
  ok "k3d found: $(k3d version | head -1)"
fi

# ── All prerequisites ready ────────────────────────────────────────
echo ""
ok "All prerequisites satisfied."
echo ""

# ── Create cluster ─────────────────────────────────────────────────
info "Creating K3d cluster: $CLUSTER_NAME"

k3d cluster create $CLUSTER_NAME \
  --servers 1 \
  --agents 2 \
  --port "8080:80@loadbalancer" \
  --port "8443:443@loadbalancer" \
  --wait

if [ $? -eq 0 ]; then
  ok "Cluster '$CLUSTER_NAME' created successfully!"
  echo ""
  info "Nodes:"
  kubectl get nodes
  echo ""
  echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║        Cluster Ready!                ║${NC}"
  echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
  echo ""
  info "Next steps:"
  info "  make deploy-all     → Deploy to K8s"
  info "  make compose-up     → Run via Docker Compose"
else
  error "Cluster creation failed."
  exit 1
fi
