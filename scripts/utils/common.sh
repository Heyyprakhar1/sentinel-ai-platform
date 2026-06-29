#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

# ============================================================
# SentinelAI Common Utilities
# Shared helper functions used by all deployment scripts
# ============================================================

# ---------- Colors ----------
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
NC="\033[0m"

# ---------- Logging ----------
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ---------- Exit ----------
die() {
    log_error "$1"
    exit 1
}

# ---------- Command Check ----------
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ---------- Retry ----------
retry() {

    local retries=5
    local delay=3

    until "$@"; do

        ((retries--))

        if [[ $retries -le 0 ]]; then
            return 1
        fi

        sleep "$delay"

    done

}
